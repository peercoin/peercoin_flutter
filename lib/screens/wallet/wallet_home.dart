import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peercoin/data_sources/electrum_backend.dart';
import 'package:peercoin/providers/server_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/available_coins.dart';
import '../../models/hive/coin_wallet.dart';
import '../../models/hive/wallet_transaction.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/connection_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/auth.dart';
import '../../tools/logger_wrapper.dart';
import '../../tools/price_ticker.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/wallet/addresses_tab.dart';
import '../../widgets/wallet/receive_tab.dart';
import '../../widgets/wallet/send_tab.dart';
import '../../widgets/wallet/transactions_list.dart';
import '../../widgets/wallet/wallet_rescan_bottom_sheet.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({Key? key}) : super(key: key);

  @override
  State<WalletHomeScreen> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHomeScreen>
    with WidgetsBindingObserver {
  bool _initial = true;
  String _unusedAddress = '';
  int _pageIndex = 1;
  int _latestBlock = 0;
  late CoinWallet _wallet;
  late BackendConnectionState _connectionState = BackendConnectionState.waiting;
  late ConnectionProvider _connectionProvider;
  late WalletProvider _walletProvider;
  late AppSettingsProvider _appSettings;
  late Iterable _listenedAddresses;
  late List<WalletTransaction> _walletTransactions = [];
  late ServerProvider _servers;
  String? _address;
  String? _label;

  void changeIndex(int i, [String? addr, String? lab]) {
    setState(() {
      _pageIndex = i;
      if (i == Tabs.send) {
        //Passes address from addresses_tab to send_tab (send to)
        _address = addr;
        _label = lab;
      }
    });
  }

  void checkPendingNotifications() async {
    if (_wallet.pendingTransactionNotifications.isNotEmpty) {
      await Future.delayed(
        const Duration(seconds: 2),
        () {
          if (_connectionProvider.openReplies.isEmpty) {
            _wallet.clearPendingTransactionNotifications();
          } else {
            checkPendingNotifications();
          }
        },
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _walletProvider.closeWallet(_wallet.name);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _connectionProvider.init(
        _wallet.name,
        requestedFromWalletHome: true,
        fromConnectivityChangeOrLifeCycle: true,
      );
      if (_appSettings.selectedCurrency.isNotEmpty) {
        PriceTicker.checkUpdate(_appSettings);
      }
      checkPendingNotifications();
    }
  }

  void _triggerRescanBottomSheet() async {
    // show bottom sheet
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return const WalletRescanBottomSheet();
      },
      context: context,
    );

    // check if _connectionProvider.openReplies has been empty for longer than 5 seconds
    bool isEmptyForFiveSeconds = false;
    Duration emptyDuration = const Duration(seconds: 0);

    while (!isEmptyForFiveSeconds) {
      if (_connectionProvider.openReplies.isEmpty) {
        await Future.delayed(const Duration(seconds: 1)); // Wait for 1 second
        emptyDuration += const Duration(seconds: 1);

        if (emptyDuration >= const Duration(seconds: 5)) {
          isEmptyForFiveSeconds = true;
        }
      } else {
        emptyDuration = const Duration(seconds: 0); // Reset the duration
        await Future.delayed(const Duration(seconds: 1)); // Wait for 1 second
      }
    }

    // scan done
    LoggerWrapper.logInfo(
      'WalletHome',
      '_triggerRescanBottomSheet',
      'scan done, removing bottom sheet',
    );

    // pop bottom sheet
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // remove flag
    _walletProvider.updateDueForRescan(_wallet.name, false);
  }

  Future<void> _performInit() async {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    _wallet = arguments['wallet'];

    _connectionProvider = Provider.of<ConnectionProvider>(context);
    _walletProvider = Provider.of<WalletProvider>(context);
    _appSettings = context.read<AppSettingsProvider>();
    _servers = Provider.of<ServerProvider>(context);

    _connectionProvider.setDataSource(
      ElectrumBackend(
        _walletProvider,
        _servers,
      ),
    );

    await _walletProvider.generateUnusedAddress(_wallet.name);
    _walletTransactions =
        await _walletProvider.getWalletTransactions(_wallet.name);
    await _connectionProvider.init(
      _wallet.name,
      requestedFromWalletHome: true,
    );

    if (_appSettings.authenticationOptions!['walletHome']!) {
      // ignore: use_build_context_synchronously
      await Auth.requireAuth(
        context: context,
        biometricsAllowed: _appSettings.biometricsAllowed,
        canCancel: false,
      );
    }

    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isAndroid) {
        if (_wallet.letterCode != 'tPPC') {
          triggerHighValueAlert();
        }
      }
    }

    checkPendingNotifications();
    // ignore: use_build_context_synchronously
    context.loaderOverlay.hide();

    if (arguments.containsKey('pushedAddress')) {
      changeIndex(Tabs.send, arguments['pushedAddress']);
    }

    //check if wallet is due for rescan
    if (_wallet.dueForRescan == true) {
      _triggerRescanBottomSheet();
    }
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      setState(() {
        _initial = false;
      });

      await _performInit();
    } else {
      _connectionState = _connectionProvider.connectionState;
      _unusedAddress = _walletProvider.getUnusedAddress(_wallet.name);

      _listenedAddresses = _connectionProvider.listenedAddresses.keys;
      if (_connectionState == BackendConnectionState.connected) {
        if (_listenedAddresses.isEmpty) {
          //listenedAddresses not populated after reconnect - resubscribe
          _connectionProvider.subscribeToScriptHashes(
            await _walletProvider.getWalletScriptHashes(_wallet.name),
          );
          //try to rebroadcast pending tx
          rebroadCastUnsendTx();
        } else if (_listenedAddresses.contains(_unusedAddress) == false) {
          //subscribe to newly created addresses
          _connectionProvider.subscribeToScriptHashes(
            await _walletProvider.getWalletScriptHashes(
              _wallet.name,
              _unusedAddress,
            ),
          );
        }
      }
      if (_connectionProvider.latestBlock > _latestBlock) {
        //new block
        LoggerWrapper.logInfo(
          'WalletHome',
          'didChangeDependencies',
          'new block ${_connectionProvider.latestBlock}',
        );
        _latestBlock = _connectionProvider.latestBlock;

        var unconfirmedTx = _walletTransactions.where(
          (element) =>
              element.confirmations < 6 &&
              element.confirmations != -1 &&
              element.timestamp != -1,
        );
        for (var element in unconfirmedTx) {
          LoggerWrapper.logInfo(
            'WalletHome',
            'didChangeDependencies',
            'requesting update for ${element.txid}',
          );
          _connectionProvider.requestTxUpdate(element.txid);
        }

        //unconfirmed balance? update balance
        if (_wallet.unconfirmedBalance > 0) {
          await _walletProvider.updateWalletBalance(_wallet.name);
        }
      }
    }

    super.didChangeDependencies();
  }

  void rebroadCastUnsendTx() {
    var nonBroadcastedTx = _walletTransactions.where(
      (element) => element.broadCasted == false && element.confirmations == 0,
    );
    for (var element in nonBroadcastedTx) {
      _connectionProvider.broadcastTransaction(
        element.broadcastHex,
        element.txid,
      );
    }
  }

  void triggerHighValueAlert() async {
    if (_appSettings.selectedCurrency.isNotEmpty) {
      //price feed enabled
      var prefs = await SharedPreferences.getInstance();
      var discarded = prefs.getBool('highValueNotice') ?? false;
      if (!discarded &&
          PriceTicker.renderPrice(
                _wallet.balance /
                    AvailableCoins.getDecimalProduct(
                      identifier: _wallet.name,
                    ),
                'USD',
                _wallet.letterCode,
                _appSettings.exchangeRates,
              ) >=
              1000) {
        //Coins worth 1000 USD or more
        // ignore: use_build_context_synchronously
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              AppLocalizations.instance.translate('wallet_value_alert_title'),
            ),
            content: Text(
              AppLocalizations.instance.translate('wallet_value_alert_content'),
            ),
            actions: <Widget>[
              TextButton.icon(
                label: Text(AppLocalizations.instance.translate('not_again')),
                icon: const Icon(Icons.cancel),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await prefs.setBool('highValueNotice', true);
                  navigator.pop();
                },
              ),
              TextButton.icon(
                label: Text(
                  AppLocalizations.instance.translate('jail_dialog_button'),
                ),
                icon: const Icon(Icons.check),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void deactivate() async {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      await _connectionProvider.closeConnection();
    }
    super.deactivate();
  }

  Future<void> _titleEditDialog(
    BuildContext context,
    CoinWallet wallet,
  ) async {
    var textFieldController = TextEditingController();
    textFieldController.text = wallet.title;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate(
              'wallet_title_edit',
            ),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: textFieldController,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: AppLocalizations.instance.translate(
                'wallet_title_edit_new_title',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<WalletProvider>().updateWalletTitle(
                      identifier: _wallet.name,
                      newTitle: textFieldController.text,
                    );
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  void selectPopUpMenuItem(String value) {
    switch (value) {
      case 'import_wallet':
        Navigator.of(context).pushNamed(
          Routes.importPaperWallet,
          arguments: _wallet.name,
        );
        break;
      case 'import_wif':
        Navigator.of(context).pushNamed(
          Routes.importWif,
          arguments: _wallet.name,
        );
        break;
      case 'signing':
        Navigator.of(context).pushNamed(
          Routes.walletMessageSigning,
          arguments: _wallet.name,
        );
        break;
      case 'verification':
        Navigator.of(context).pushNamed(
          Routes.walletMessageVerification,
          arguments: _wallet.name,
        );
        break;
      case 'change_title':
        _titleEditDialog(context, _wallet);
        break;
      default:
    }
  }

  List<Widget> _calcPopupMenuItems(BuildContext context) {
    return [
      PopupMenuButton(
        onSelected: (dynamic value) => selectPopUpMenuItem(value),
        itemBuilder: (_) {
          return [
            if (_appSettings.camerasAvailble)
              PopupMenuItem(
                value: 'import_wallet',
                child: ListTile(
                  leading: Icon(
                    Icons.arrow_circle_down,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    AppLocalizations.instance
                        .translate('wallet_pop_menu_paperwallet'),
                  ),
                ),
              ),
            PopupMenuItem(
              value: 'import_wif',
              child: ListTile(
                leading: Icon(
                  Icons.arrow_circle_down,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance.translate('wallet_pop_menu_wif'),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'signing',
              child: ListTile(
                leading: Icon(
                  Icons.key,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance
                      .translate('wallet_pop_menu_signing'),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'verification',
              child: ListTile(
                leading: Icon(
                  Icons.fact_check,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance
                      .translate('wallet_pop_menu_verification'),
                ),
              ),
            ),
            PopupMenuItem(
              value: 'change_title',
              child: ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  AppLocalizations.instance
                      .translate('wallet_pop_menu_change_title'),
                ),
              ),
            ),
          ];
        },
      )
    ];
  }

  BottomNavigationBar _calcBottomNavBar(BuildContext context) {
    final back = Theme.of(context).primaryColor;
    return BottomNavigationBar(
      unselectedItemColor: Theme.of(context).disabledColor,
      selectedItemColor: Colors.white,
      onTap: (index) => changeIndex(index),
      currentIndex: _pageIndex,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.download_rounded),
          label:
              AppLocalizations.instance.translate('wallet_bottom_nav_receive'),
          backgroundColor: back,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_rounded),
          label: AppLocalizations.instance.translate('wallet_bottom_nav_tx'),
          backgroundColor: back,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.menu_book_rounded),
          label: AppLocalizations.instance.translate('wallet_bottom_nav_addr'),
          backgroundColor: back,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.upload_rounded),
          label: AppLocalizations.instance.translate('wallet_bottom_nav_send'),
          backgroundColor: back,
        )
      ],
    );
  }

  Widget _calcBody() {
    Widget body;
    switch (_pageIndex) {
      case Tabs.receive:
        body = Expanded(
          child: ReceiveTab(
            connectionState: _connectionState,
            wallet: _wallet,
            unusedAddress: _unusedAddress,
          ),
        );
        break;
      case Tabs.transactions:
        body = Expanded(
          child: TransactionList(
            walletTransactions: _walletTransactions,
            wallet: _wallet,
            connectionState: _connectionState,
          ),
        );
        break;
      case Tabs.addresses:
        body = Expanded(
          child: AddressTab(
            walletName: _wallet.name,
            title: _wallet.title,
            walletAddresses: _wallet.addresses,
            changeIndex: changeIndex,
          ),
        );
        break;
      case Tabs.send:
        body = Expanded(
          child: SendTab(
            address: _address,
            label: _label,
            wallet: _wallet,
            connectionState: _connectionState,
            changeIndex: changeIndex,
          ),
        );
        break;
      default:
        body = const SizedBox();
        break;
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _calcBottomNavBar(context),
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text(_wallet.title),
        actions: _calcPopupMenuItems(context),
      ),
      body: _initial
          ? const Center(
              child: LoadingIndicator(),
            )
          : Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  _calcBody(),
                ],
              ),
            ),
    );
  }

  // TODO check cursive roboto on iOS
  // TODO wallet list: make larger list prettier
}

class Tabs {
  Tabs._();
  static const int receive = 0;
  static const int transactions = 1;
  static const int addresses = 2;
  static const int send = 3;
}
