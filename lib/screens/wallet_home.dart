import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/addresses_tab.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/receive_tab.dart';
import 'package:peercoin/widgets/send_tab.dart';
import 'package:peercoin/widgets/transactions_list.dart';
import 'package:provider/provider.dart';

class WalletHomeScreen extends StatefulWidget {
  @override
  _WalletHomeState createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHomeScreen>
    with WidgetsBindingObserver {
  bool _initial = true;
  bool _rescanInProgress = false;
  String _unusedAddress = '';
  late CoinWallet _wallet;
  int _pageIndex = 1;
  late ElectrumConnectionState _connectionState =
      ElectrumConnectionState.waiting;
  ElectrumConnection? _connectionProvider;
  late ActiveWallets _activeWallets;
  late Iterable _listenedAddresses;
  late List<WalletTransaction> _walletTransactions = [];
  int _latestBlock = 0;
  String? _address;
  String? _label;
  String _filterChoice = 'all';

  void changeIndex(int i, [String? addr, String? lab]) {
    if (i == Tabs.send) {
      //Passes address from addresses_tab to send_tab (send to)
      _address = addr;
      _label = lab;
    }
    setState(() {
      _pageIndex = i;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _connectionProvider!
          .init(_wallet.name, requestedFromWalletHome: true);
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      setState(() {
        _initial = false;
      });

      _wallet = ModalRoute.of(context)!.settings.arguments as CoinWallet;
      _connectionProvider = Provider.of<ElectrumConnection>(context);
      _activeWallets = Provider.of<ActiveWallets>(context);
      await _activeWallets.generateUnusedAddress(_wallet.name);
      _walletTransactions =
          await _activeWallets.getWalletTransactions(_wallet.name);
      await _connectionProvider!
          .init(_wallet.name, requestedFromWalletHome: true);

      var _appSettings = Provider.of<AppSettings>(context, listen: false);
      if (_appSettings.authenticationOptions!['walletHome']!) {
        await Auth.requireAuth(context, _appSettings.biometricsAllowed);
      }
    } else if (_connectionProvider != null) {
      _connectionState = _connectionProvider!.connectionState;
      _unusedAddress = _activeWallets.getUnusedAddress;

      _listenedAddresses = _connectionProvider!.listenedAddresses.keys;
      if (_connectionState == ElectrumConnectionState.connected) {
        if (_listenedAddresses.isEmpty) {
          //listenedAddresses not populated after reconnect - resubscribe
          _connectionProvider!.subscribeToScriptHashes(
              await _activeWallets.getWalletScriptHashes(_wallet.name));
          //try to rebroadcast pending tx
          rebroadCastUnsendTx();
        } else if (_listenedAddresses.contains(_unusedAddress) == false) {
          //subscribe to newly created addresses
          _connectionProvider!.subscribeToScriptHashes(await _activeWallets
              .getWalletScriptHashes(_wallet.name, _unusedAddress));
        }
      }
      if (_connectionProvider!.latestBlock > _latestBlock) {
        //new block
        print('new block ${_connectionProvider!.latestBlock}');
        _latestBlock = _connectionProvider!.latestBlock;

        var unconfirmedTx = _walletTransactions.where((element) =>
            element.confirmations < 6 &&
                element.confirmations != -1 &&
                element.timestamp != -1 ||
            element.timestamp == null);
        unconfirmedTx.forEach((element) {
          print('requesting update for ${element.txid}');
          _connectionProvider!.requestTxUpdate(element.txid);
        });
      }
    }

    super.didChangeDependencies();
  }

  void rebroadCastUnsendTx() {
    var nonBroadcastedTx = _walletTransactions.where((element) =>
        element.broadCasted == false && element.confirmations == 0);
    nonBroadcastedTx.forEach((element) {
      _connectionProvider!.broadcastTransaction(
        element.broadcastHex,
        element.txid,
      );
    });
  }

  @override
  void deactivate() async {
    if (_rescanInProgress == false) {
      await _connectionProvider!.closeConnection();
    }
    super.deactivate();
  }

  void selectPopUpMenuItem(String value) {
    if (value == 'import_wallet') {
      Navigator.of(context)
          .pushNamed(Routes.ImportPaperWallet, arguments: _wallet.name);
    } else if (value == 'server_settings') {
      Navigator.of(context)
          .pushNamed(Routes.ServerSettings, arguments: _wallet.name);
    } else if (value == 'rescan') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title:
              Text(AppLocalizations.instance.translate('wallet_rescan_title')),
          content: Text(
              AppLocalizations.instance.translate('wallet_rescan_content')),
          actions: <Widget>[
            TextButton.icon(
                label: Text(AppLocalizations.instance
                    .translate('server_settings_alert_cancel')),
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton.icon(
              label: Text(
                  AppLocalizations.instance.translate('jail_dialog_button')),
              icon: Icon(Icons.check),
              onPressed: () async {
                //close connection
                await _connectionProvider!.closeConnection();
                _rescanInProgress = true;
                //init rescan
                await Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.WalletImportScan, (_) => false,
                    arguments: _wallet.name);
              },
            ),
          ],
        ),
      );
    }
  }

  void _handleSelect(String newChoice) {
    setState(() {
      _filterChoice = newChoice;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var body;
    var barTitle;

    switch (_pageIndex) {
      case Tabs.receive:
        body = ReceiveTab(_unusedAddress, _connectionState);
        break;
      case Tabs.transactions:
        body = TransactionList(
          _walletTransactions,
          _wallet,
          _connectionState,
          _filterChoice,
        );
        break;
      case Tabs.addresses:
        body = AddressTab(
          _wallet.name,
          _wallet.title,
          _wallet.addresses,
          changeIndex,
        );
        break;
      case Tabs.send:
        body = SendTab(changeIndex, _address, _label, _connectionState);
        break;

      default:
        body = Container();
        break;
    };

    if (_connectionState == ElectrumConnectionState.connected) {
      barTitle = Text(
        AppLocalizations.instance.translate('wallet_connected'),
        style: TextStyle(
          color: Theme.of(context).backgroundColor,
          letterSpacing: 1.4,
          fontSize: 16,
        ),
      );
    } else if (_connectionState == ElectrumConnectionState.offline) {
      barTitle = Text(
        AppLocalizations.instance.translate('wallet_offline'),
        style: TextStyle(
          color: Theme.of(context).backgroundColor,
          fontSize: 16,
          letterSpacing: 1.4,
        ),
      );
    } else {
      barTitle = Container(width: 88, child: LoadingIndicator());
    }

    return Scaffold(
      backgroundColor: theme.primaryColor,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: theme.disabledColor,
        selectedItemColor: theme.backgroundColor,
        onTap: (index) => changeIndex(index),
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            label: AppLocalizations.instance
                .translate('wallet_bottom_nav_receive'),
            backgroundColor: theme.primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: AppLocalizations.instance.translate('wallet_bottom_nav_tx'),
            backgroundColor: theme.primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label:
                AppLocalizations.instance.translate('wallet_bottom_nav_addr'),
            backgroundColor: theme.primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_rounded),
            label:
                AppLocalizations.instance.translate('wallet_bottom_nav_send'),
            backgroundColor: theme.primaryColor,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              forceElevated: true,
              elevation: 2,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: barTitle,
              centerTitle: true,
              actions: [
                PopupMenuButton(
                  onSelected: (dynamic value) => selectPopUpMenuItem(value),
                  itemBuilder: (_) {
                    return [
                      PopupMenuItem(
                        value: 'import_wallet',
                        child: ListTile(
                          leading: Icon(Icons.arrow_circle_down),
                          title: Text(
                            AppLocalizations.instance
                                .translate('wallet_pop_menu_paperwallet'),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'server_settings',
                        child: ListTile(
                          leading: Icon(Icons.sync),
                          title: Text(
                            AppLocalizations.instance
                                .translate('wallet_pop_menu_servers'),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rescan',
                        child: ListTile(
                          leading: Icon(Icons.sync_problem),
                          title: Text(
                            AppLocalizations.instance
                                .translate('wallet_pop_menu_rescan'),
                          ),
                        ),
                      )
                    ];
                  },
                )
              ],
            ),
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: theme.primaryColor,
              title: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          (_wallet.balance / 1000000).toString(),
                          style: TextStyle(
                            fontSize: 26,
                            color: theme.backgroundColor,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _wallet.unconfirmedBalance > 0
                            ? Text(
                                (_wallet.unconfirmedBalance / 1000000).toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[200],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      _wallet.letterCode + '  |  ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[100],
                      ),
                    ),
                    Center(
                      child: Text(
                        _wallet.title,
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.backgroundColor,
                          //letterSpacing: 1.2,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(padding: const EdgeInsets.only(bottom: 24)),
            SliverVisibility(
              visible: _pageIndex == Tabs.transactions,
              sliver: SliverToBoxAdapter(
                child: Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Wrap(
                        spacing: 8.0,
                        children: <Widget>[
                          ChoiceChip(
                            backgroundColor: Theme.of(context).backgroundColor,
                            selectedColor: Theme.of(context).shadowColor,
                            visualDensity:
                                VisualDensity(horizontal: 0.0, vertical: -4),
                            label: Container(
                                child: Text(
                              AppLocalizations.instance
                                  .translate('transactions_in'),
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                            )),
                            selected: _filterChoice == 'in',
                            onSelected: (_) => _handleSelect('in'),
                          ),
                          ChoiceChip(
                            backgroundColor: Theme.of(context).backgroundColor,
                            selectedColor: Theme.of(context).shadowColor,
                            visualDensity:
                                VisualDensity(horizontal: 0.0, vertical: -4),
                            label: Text(
                                AppLocalizations.instance
                                    .translate('transactions_all'),
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                )),
                            selected: _filterChoice == 'all',
                            onSelected: (_) => _handleSelect('all'),
                          ),
                          ChoiceChip(
                            backgroundColor: Theme.of(context).backgroundColor,
                            selectedColor: Theme.of(context).shadowColor,
                            visualDensity:
                                VisualDensity(horizontal: 0.0, vertical: -4),
                            label: Text(
                                AppLocalizations.instance
                                    .translate('transactions_out'),
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                )),
                            selected: _filterChoice == 'out',
                            onSelected: (_) => _handleSelect('out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body,
          ],
        ),
      ),
    );
  }
}

class Tabs {
  Tabs._();
  static const int receive = 0;
  static const int transactions = 1;
  static const int addresses = 2;
  static const int send = 3;
}
