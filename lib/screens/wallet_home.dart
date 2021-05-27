import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
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
import 'package:peercoin/widgets/wallet_home_qr.dart';
import 'package:provider/provider.dart';

class WalletHomeScreen extends StatefulWidget {
  @override
  _WalletHomeState createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHomeScreen>
    with WidgetsBindingObserver {
  bool _initial = true;
  bool _rescanInProgress = false;
  String? _unusedAddress = '';
  CoinWallet? _wallet;
  int _pageIndex = 1;
  ElectrumConnectionState? _connectionState;
  ElectrumConnection? _connectionProvider;
  late ActiveWallets _activeWallets;
  late Iterable _listenedAddresses;
  List<WalletTransaction>? _walletTransactions;
  int? _latestBlock = 0;

  void changeIndex(int i) {
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
      await _connectionProvider!.init(_wallet!.name,
          requestedFromWalletHome: true);
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      setState(() {
        _initial = false;
      });

      _wallet = ModalRoute.of(context)!.settings.arguments as CoinWallet?;
      _connectionProvider = Provider.of<ElectrumConnection>(context);
      _activeWallets = Provider.of<ActiveWallets>(context);
      await _activeWallets.generateUnusedAddress(_wallet!.name);
      _walletTransactions =
          await _activeWallets.getWalletTransactions(_wallet!.name);
      await _connectionProvider!.init(_wallet!.name,
          requestedFromWalletHome: true);

      var _appSettings = Provider.of<AppSettings>(context, listen: false);
      if (_appSettings.authenticationOptions!['walletHome']!) {
        await Auth.requireAuth(context, _appSettings.biometricsAllowed!);
      }
    } else if (_connectionProvider != null) {
      _connectionState = _connectionProvider!.connectionState;
      _unusedAddress = _activeWallets.getUnusedAddress;

      _listenedAddresses = _connectionProvider!.listenedAddresses.keys;
      if (_connectionState == ElectrumConnectionState.connected) {
        if (_listenedAddresses.isEmpty) {
          //listenedAddresses not populated after reconnect - resubscribe
          _connectionProvider!.subscribeToScriptHashes(
              await _activeWallets.getWalletScriptHashes(_wallet!.name));
          //try to rebroadcast pending tx
          rebroadCastUnsendTx();
        } else if (_listenedAddresses.contains(_unusedAddress) == false) {
          //subscribe to newly created addresses
          _connectionProvider!.subscribeToScriptHashes(await _activeWallets
              .getWalletScriptHashes(_wallet!.name, _unusedAddress));
        }
      }
      if (_connectionProvider!.latestBlock != null) {
        if (_connectionProvider!.latestBlock! > _latestBlock!) {
          //new block
          print('new block ${_connectionProvider!.latestBlock}');
          _latestBlock = _connectionProvider!.latestBlock;

          var unconfirmedTx = _walletTransactions!.where((element) =>
              element.confirmations! < 6 && element.timestamp != -1);
          unconfirmedTx.forEach((element) {
            print('requesting update for ${element.txid}');
            _connectionProvider!.requestTxUpdate(element.txid);
          });
        }
      }
    }

    super.didChangeDependencies();
  }

  void rebroadCastUnsendTx() {
    var nonBroadcastedTx =
        _walletTransactions!.where((element) => element.broadCasted == false);
    nonBroadcastedTx.forEach((element) {
      _connectionProvider!.broadcastTransaction(
        element.broadcastHex,
        element.txid,
      );
    });
  }

  @override
  void deactivate() async {
    if (_rescanInProgress == false) await _connectionProvider!.closeConnection();
    super.deactivate();
  }

  void selectPopUpMenuItem(String value) {
    if (value == 'import_wallet') {
      Navigator.of(context)
          .pushNamed(Routes.ImportPaperWallet, arguments: _wallet!.name);
    } else if (value == 'server_settings') {
      Navigator.of(context)
          .pushNamed(Routes.ServerSettings, arguments: _wallet!.name);
    } else if (value == 'rescan') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title:
              Text(AppLocalizations.instance.translate('wallet_rescan_title')!),
          content: Text(
              AppLocalizations.instance.translate('wallet_rescan_content')!),
          actions: <Widget>[
            TextButton.icon(
                label: Text(AppLocalizations.instance
                    .translate('server_settings_alert_cancel')!),
                icon: Icon(Icons.cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton.icon(
              label: Text(
                  AppLocalizations.instance.translate('jail_dialog_button')!),
              icon: Icon(Icons.check),
              onPressed: () async {
                //close connection
                await _connectionProvider!.closeConnection();
                _rescanInProgress = true;
                //init rescan
                await Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.WalletImportScan, (_) => false,
                    arguments: _wallet!.name);
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        fixedColor: Colors.white,
        unselectedLabelStyle: TextStyle(letterSpacing: 1.5),
        onTap: (index) => changeIndex(index),
        currentIndex: _pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.download_sharp),
            label: AppLocalizations.instance
                .translate('wallet_bottom_nav_receive'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: AppLocalizations.instance.translate('wallet_bottom_nav_tx'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_sharp),
            label:
                AppLocalizations.instance.translate('wallet_bottom_nav_send'),
          )
        ],
      ),
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
              AvailableCoins()
                  .getSpecificCoin(_wallet!.name)!
                  .iconPathTransparent,
              width: 20),
          SizedBox(width: 10),
          Text(_wallet!.title!)
        ]),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book),
            onPressed: () async {
              _activeWallets.transferedAddress = null;
              final _result = await Navigator.of(context).pushNamed(
                  Routes.AddressBook,
                  arguments: {'name': _wallet!.name, 'title': _wallet!.title});
              if (_result != null) {
                setState(() {
                  _activeWallets.transferedAddress = _result;
                });
                changeIndex(2);
              }
            },
          ),
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
                          .translate('wallet_pop_menu_paperwallet')!,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'server_settings',
                  child: ListTile(
                    leading: Icon(Icons.sync),
                    title: Text(
                      AppLocalizations.instance
                          .translate('wallet_pop_menu_servers')!,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'rescan',
                  child: ListTile(
                    leading: Icon(Icons.sync_problem),
                    title: Text(
                      AppLocalizations.instance
                          .translate('wallet_pop_menu_rescan')!,
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
          : Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      _wallet!.letterCode!,
                      style: TextStyle(
                          fontSize: 26, color: Theme.of(context).accentColor),
                    ),
                    Column(
                      children: [
                        Text(
                          (_wallet!.balance! / 1000000).toString(),
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        _wallet!.unconfirmedBalance! > 0
                            ? Text(
                                (_wallet!.unconfirmedBalance! / 1000000)
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).accentColor),
                              )
                            : Container(),
                      ],
                    ),
                    WalletHomeQr(_unusedAddress)
                  ],
                ),
                WalletHomeConnection(_connectionState),
                Divider(),
                WalletContentSwitch(
                  pageIndex: _pageIndex,
                  walletTransactions: _walletTransactions,
                  unusedAddress: _unusedAddress,
                  changeIndex: changeIndex,
                  identifier: _wallet!.name,
                )
              ],
            ),
    );
  }
}
