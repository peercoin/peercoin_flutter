import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/app_themes.dart';
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

  void changeIndex(int i,[String? addr,String? lab]) {
    if (i==Tabs.send) {
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

        var unconfirmedTx = _walletTransactions.where(
            (element) => element.confirmations < 6 && element.timestamp != -1);
        unconfirmedTx.forEach((element) {
          print('requesting update for ${element.txid}');
          _connectionProvider!.requestTxUpdate(element.txid);
        });
      }
    }

    super.didChangeDependencies();
  }

  void rebroadCastUnsendTx() {
    var nonBroadcastedTx =
        _walletTransactions.where((element) => element.broadCasted == false);
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

  @override
  Widget build(BuildContext context) {
    var back = Theme.of(context).primaryColor;
    var body;
    switch (_pageIndex) {
      case Tabs.receive:
        body = Expanded(child: ReceiveTab(_unusedAddress, _connectionState));
        break;
      case Tabs.transactions:
        body = Expanded(
          child: TransactionList(
            _walletTransactions,
            _wallet,
            _connectionState,
          ),
        );
        break;
      case Tabs.addresses:
        body = Expanded(
            child: AddressTab(
          _wallet.name,
          _wallet.title,
          _wallet.addresses,
          changeIndex,
        ));
        break;
      case Tabs.send:
        body = Expanded(
          child: SendTab(changeIndex, _address, _label, _connectionState),
        );
        break;

      default:
        body = Container();
        break;
    }
    ;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).disabledColor,
        selectedItemColor: Colors.white,
        onTap: (index) => changeIndex(index),
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            label: AppLocalizations.instance
                .translate('wallet_bottom_nav_receive'),
            backgroundColor: back,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: AppLocalizations.instance.translate('wallet_bottom_nav_tx'),
            backgroundColor: back,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Addresses',
            backgroundColor: back,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_rounded),
            label:
                AppLocalizations.instance.translate('wallet_bottom_nav_send'),
            backgroundColor: back,
          ),
        ],
      ),
      appBar: AppBar(
        elevation: 1,
        title: Center(child: Text(_wallet.title)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(Routes.WalletList);
          },
        ),
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
      body: _initial
          ? Center(child: LoadingIndicator())
          : Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  body,
                ],
              ),
            ),
    );
  }
}


/// Widgets that should be moved from here... **/

class PeerButton extends StatelessWidget {
  final Function() action;
  final String text;
  final bool small;
  final bool active;
  PeerButton({required this.text, required this.action, this.small=false, this.active=true});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        onPrimary: Theme.of(context).accentColor,
        fixedSize: Size(MediaQuery.of(context).size.width/(small?2:1.5), 40),
        shape: RoundedRectangleBorder( //to set border radius to button
            borderRadius: BorderRadius.circular(30)
        ),
        elevation: 0,
      ),
      onPressed: action,
      child: Text(
        text,
        style: TextStyle(
            letterSpacing: 1.4,
            fontSize: 16,
            color: active?LightColors.white:LightColors.grey,
        ),
      ),
    );
  }
}

class PeerButtonBorder extends StatelessWidget {
  final Function() action;
  final String text;
  PeerButtonBorder({required this.text, required this.action});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).backgroundColor,
        onPrimary: Theme.of(context).backgroundColor,
        fixedSize: Size(MediaQuery.of(context).size.width/1.5, 40),
        shape: RoundedRectangleBorder( //to set border radius to button
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(width:2, color:Theme.of(context).primaryColor),
        ),
        elevation: 0,
      ),
      onPressed: action,
      child: Text(
        text,
        style: TextStyle(
            letterSpacing: 1.4,
            fontSize: 16,
            color: Theme.of(context).primaryColor),
      ),
    );
  }
}


class PeerServiceTitle extends StatelessWidget {
  final String title;
  PeerServiceTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: MediaQuery.of(context).size.width/10,
              child: Divider(
                color: Theme.of(context).primaryColor,
                thickness: 3,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PeerContainer extends StatelessWidget {
  final Widget child;
  PeerContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).backgroundColor,
      ),
      child: child,
    );
  }
}

class Tabs{
  Tabs._();
  static const int receive = 0;
  static const int transactions = 1;
  static const int addresses = 2;
  static const int send = 3;

}
