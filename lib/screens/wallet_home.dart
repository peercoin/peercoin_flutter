import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/app_drawer.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/wallet_content_switch.dart';
import 'package:peercoin/widgets/wallet_home_connection.dart';
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
  CoinWallet _wallet;
  int _pageIndex = 1;
  ElectrumConnectionState _connectionState;
  ElectrumConnection _connectionProvider;
  ActiveWallets _activeWallets;
  Iterable _listenedAddresses;
  List<WalletTransaction> _walletTransactions;
  int _latestBlock = 0;

  void changeIndex(int i) {
    setState(() {
      _pageIndex = i;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _connectionProvider.init(_wallet.name,
          requestedFromWalletHome: true);
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      setState(() {
        _initial = false;
      });

      _wallet = ModalRoute.of(context).settings.arguments as CoinWallet;
      _connectionProvider = Provider.of<ElectrumConnection>(context);
      _activeWallets = Provider.of<ActiveWallets>(context);
      await _activeWallets.generateUnusedAddress(_wallet.name);
      _walletTransactions =
          await _activeWallets.getWalletTransactions(_wallet.name);
      await _connectionProvider.init(_wallet.name,
          requestedFromWalletHome: true);

      var _appSettings = Provider.of<AppSettings>(context, listen: false);
      if (_appSettings.authenticationOptions['walletHome']) {
        await Auth.requireAuth(context, _appSettings.biometricsAllowed);
      }
    } else if (_connectionProvider != null) {
      _connectionState = _connectionProvider.connectionState;
      _unusedAddress = _activeWallets.getUnusedAddress;

      _listenedAddresses = _connectionProvider.listenedAddresses.keys;
      if (_connectionState == ElectrumConnectionState.connected) {
        if (_listenedAddresses.isEmpty) {
          //listenedAddresses not populated after reconnect - resubscribe
          _connectionProvider.subscribeToScriptHashes(
              await _activeWallets.getWalletScriptHashes(_wallet.name));
          //try to rebroadcast pending tx
          rebroadCastUnsendTx();
        } else if (_listenedAddresses.contains(_unusedAddress) == false) {
          //subscribe to newly created addresses
          _connectionProvider.subscribeToScriptHashes(await _activeWallets
              .getWalletScriptHashes(_wallet.name, _unusedAddress));
        }
      }
      if (_connectionProvider.latestBlock != null) {
        if (_connectionProvider.latestBlock > _latestBlock) {
          //new block
          print('new block ${_connectionProvider.latestBlock}');
          _latestBlock = _connectionProvider.latestBlock;

          var unconfirmedTx = _walletTransactions.where((element) =>
              element.confirmations < 6 && element.timestamp != -1);
          unconfirmedTx.forEach((element) {
            print('requesting update for ${element.txid}');
            _connectionProvider.requestTxUpdate(element.txid);
          });
        }
      }
    }

    super.didChangeDependencies();
  }

  void rebroadCastUnsendTx() {
    var nonBroadcastedTx =
        _walletTransactions.where((element) => element.broadCasted == false);
    nonBroadcastedTx.forEach((element) {
      _connectionProvider.broadcastTransaction(
        element.broadcastHex,
        element.txid,
      );
    });
  }

  @override
  void deactivate() async {
    if (_rescanInProgress == false) await _connectionProvider.closeConnection();
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
                await _connectionProvider.closeConnection();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      /*bottomNavigationBar: BottomNavigationBar(
    unselectedItemColor: PeerColors.darkGreen,
    selectedItemColor: Colors.white,
    onTap: (index) => changeIndex(index),
    currentIndex: _pageIndex,
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.download_rounded),
        label: AppLocalizations.instance.translate('wallet_bottom_nav_receive'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.list_rounded),
        label: AppLocalizations.instance.translate('wallet_bottom_nav_tx'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.menu_book_rounded),
        label: 'Addresses',
        backgroundColor: Theme.of(context).primaryColor,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.upload_rounded),
        label: AppLocalizations.instance.translate('wallet_bottom_nav_send'),
        backgroundColor: Theme.of(context).primaryColor,
      )
    ],
  ),*/
      appBar: AppBar(
        elevation: 0,
        title: Center(child: Text(_wallet.title)),
        actions: [
          PopupMenuButton(
            onSelected: (value) => selectPopUpMenuItem(value),
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
      body: _initial
          ? Center(child: LoadingIndicator())
          : Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  Column(
                    children: [
                      WalletHomeConnection(_connectionState),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                (_wallet.balance / 1000000).toString(),
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              _wallet.unconfirmedBalance > 0
                                  ? Text(
                                      (_wallet.unconfirmedBalance / 1000000)
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).accentColor),
                                    )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            _wallet.letterCode,
                            style: TextStyle(
                              fontSize: 26,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PeerIconButton(
                        icon: Icons.download_rounded,
                        action: () {
                          setState(() {
                            _pageIndex = 0;
                          });
                        },
                      ),
                      PeerIconButton(
                        icon: Icons.menu_book,
                        action: () async {
                          _activeWallets.transferedAddress = null;
                          final _result = await Navigator.of(context)
                              .pushNamed(Routes.AddressBook, arguments: {
                            'name': _wallet.name,
                            'title': _wallet.title
                          });
                          if (_result != null) {
                            setState(() {
                              _activeWallets.transferedAddress = _result;
                            });
                            changeIndex(2);
                          }
                        },
                      ),
                      PeerIconButton(
                        icon: Icons.list,
                        action: () {
                          setState(() {
                            _pageIndex = 1;
                          });
                        },
                      ),
                      PeerIconButton(
                        icon: Icons.upload_rounded,
                        action: () {
                          setState(() {
                            _pageIndex = 2;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  WalletContentSwitch(
                    pageIndex: _pageIndex,
                    walletTransactions: _walletTransactions,
                    unusedAddress: _unusedAddress,
                    changeIndex: changeIndex,
                    identifier: _wallet.name,
                  )
                ],
              ),
            ),
    );
  }
}

class PeerIconButton extends StatelessWidget {
  final Function action;
  final IconData icon;
  PeerIconButton({this.icon, this.action});
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: action,
      elevation: 0,
      fillColor: Theme.of(context).accentColor,
      padding: const EdgeInsets.all(10),
      shape: CircleBorder(),
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      child: Icon(
        icon,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}

class PeerServiceTitle extends StatelessWidget {
  final String title;
  PeerServiceTitle({this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class PeerContainer extends StatelessWidget {
  final Widget child;
  PeerContainer({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).backgroundColor,
      ),
      child: child,
    );
  }
}




