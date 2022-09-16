import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:peercoin/providers/app_settings.dart';
import 'package:provider/provider.dart';

import '../../providers/active_wallets.dart';
import '../../providers/electrum_connection.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/background_sync.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/loading_indicator.dart';

class WalletImportScanScreen extends StatefulWidget {
  const WalletImportScanScreen({Key? key}) : super(key: key);

  @override
  State<WalletImportScanScreen> createState() => _WalletImportScanScreenState();
}

class _WalletImportScanScreenState extends State<WalletImportScanScreen> {
  bool _initial = true;
  bool _scanStarted = false;
  bool backgroundNotificationsAvailable = false;
  ElectrumConnection? _connectionProvider;
  late ActiveWallets _activeWallets;
  late AppSettings _settings;
  late String _coinName = '';
  late ElectrumConnectionState _connectionState;
  int _latestUpdate = 0;
  int _addressScanPointer = 0;
  int _addressChunkSize = 10;
  late Timer _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.instance.translate('wallet_scan_appBar_title'),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.instance.translate('wallet_scan_notice'),
          ),
          const SizedBox(height: 20),
          PeerButton(
            text: AppLocalizations.instance
                .translate('server_settings_alert_cancel'),
            action: () async {
              _timer.cancel();
              await Navigator.of(context).pushReplacementNamed(
                Routes.walletList,
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void deactivate() async {
    await _connectionProvider!.closeConnection();
    _timer.cancel();
    super.deactivate();
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      setState(() {
        _initial = false;
      });
      _coinName = ModalRoute.of(context)!.settings.arguments as String;
      _connectionProvider = Provider.of<ElectrumConnection>(context);
      _activeWallets = Provider.of<ActiveWallets>(context);
      _settings = Provider.of<AppSettings>(context, listen: false);
      await _activeWallets.prepareForRescan(_coinName);
      await _connectionProvider!.init(_coinName, scanMode: true);

      _timer = Timer.periodic(const Duration(seconds: 7), (timer) async {
        var dueTime = _latestUpdate + 7;
        if (_connectionState == ElectrumConnectionState.waiting) {
          await _connectionProvider!.init(_coinName, scanMode: true);
        } else if (dueTime <= DateTime.now().millisecondsSinceEpoch ~/ 1000 &&
            _scanStarted == true) {
          //tasks to finish after timeout
          final navigator = Navigator.of(context);
          //sync notification backend
          await BackgroundSync.executeSync(fromScan: true);
          _timer.cancel();
          await navigator.pushReplacementNamed(
            Routes.walletList,
            arguments: {'fromScan': true},
          );
        }
      });

      if (_settings.notificationInterval > 0) {
        setState(() {
          backgroundNotificationsAvailable = true;
        });
        await fetchAddressesFromBackend();
      }
    } else if (_connectionProvider != null) {
      _connectionState = _connectionProvider!.connectionState;
      if (_connectionState == ElectrumConnectionState.connected) {
        _latestUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (backgroundNotificationsAvailable == false) {
          startScan();
        }
      }
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchAddressesFromBackend() async {
    var adressesToQuery = <String, int>{};
    for (int i = _addressScanPointer;
        i < _addressScanPointer + _addressChunkSize;
        i++) {
      var res = await _activeWallets.getAddressFromDerivationPath(
        identifier: _coinName,
        account: 0,
        chain: i,
        address: 0,
      );
      adressesToQuery[res!] = 0;
    }

    await parseBackendResult(
      await BackgroundSync.getDataFromAddressBackend(
        _coinName,
        adressesToQuery,
      ),
    );
  }

  Future<void> parseBackendResult(Response response) async {
    bool foundDifference;
    if (response.body.contains('foundDifference')) {
      //valid answer
      var bodyDecoded = jsonDecode(response.body);
      LoggerWrapper.logInfo(
        'WalletImportScan',
        'parseBackendResult',
        bodyDecoded.toString(),
      );
      foundDifference = bodyDecoded['foundDifference'];
      if (foundDifference == true) {
        //loop through addresses in result
        var addresses = bodyDecoded['addresses'];
        addresses.forEach(
          (element) {
            var elementAddr = element['address'];
            //backend knows this addr
            if (element['utxos'] == true) {
              _activeWallets.addAddressFromScan(_coinName, elementAddr, 'null');
            }
          },
        );

        //keep searching in next chunk
        setState(() {
          _addressScanPointer += _addressChunkSize;
          _addressChunkSize += 5;
        });
        fetchAddressesFromBackend();
      } else {
        //no more differences found
        startScan();
      }
    }
  }

  void startScan() async {
    if (_scanStarted == false) {
      LoggerWrapper.logInfo('WalletImportScan', 'startScan', 'Scan started');
      //returns master address for hd wallet
      var masterAddr = await _activeWallets.getAddressFromDerivationPath(
        identifier: _coinName,
        account: 0,
        chain: 0,
        address: 0,
        isMaster: true,
      );

      //subscribe to hd master
      _connectionProvider!.subscribeToScriptHashes(
        await _activeWallets.getWalletScriptHashes(
          _coinName,
          masterAddr,
        ),
      );

      setState(() {
        _scanStarted = true;
      });
    }
  }
}
