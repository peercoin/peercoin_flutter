import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/data_sources/data_source.dart';
import 'package:peercoin/providers/app_settings_provider.dart';
import 'package:peercoin/providers/server_provider.dart';
import 'package:peercoin/tools/wallet_scanner.dart';
import 'package:provider/provider.dart';

import '../../../providers/connection_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';
import '../../../tools/app_routes.dart';
import '../../../tools/background_sync.dart';
import '../../../tools/logger_wrapper.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/loading_indicator.dart';

class AppSettingsWalletScanLandingScreen extends StatefulWidget {
  const AppSettingsWalletScanLandingScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsWalletScanLandingScreen> createState() =>
      _AppSettingsWalletScanLandingScreenState();
}

class _AppSettingsWalletScanLandingScreenState
    extends State<AppSettingsWalletScanLandingScreen> {
  bool _initial = true;
  bool _scanStarted = false;
  bool _backgroundNotificationsAvailable = false;
  ConnectionProvider? _connectionProvider;
  late WalletProvider _walletProvider;
  late AppSettingsProvider _settings;
  late String _coinName = '';
  late BackendConnectionState _connectionState;
  late int _walletNumber;
  int _addressScanPointer = 0;
  int _addressChunkSize = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate(
            'wallet_scan_appBar_title',
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
          if (_backgroundNotificationsAvailable == false && !kIsWeb)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.instance.translate(
                      'wallet_scan_notice_bg_notifications',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          PeerButton(
            text: AppLocalizations.instance
                .translate('server_settings_alert_cancel'),
            action: () async {
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
//TODO tell current scanner to stop
    super.deactivate();
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      final scanner = WalletScanner(
        accountNumber: 0,
        coinName: 'peercoin',
        backend: BackendType.electrum,
        serverProvider: Provider.of<ServerProvider>(context),
        walletProvider: Provider.of<WalletProvider>(context),
      );
      scanner.startScan().listen((event) {
        print(event.message);
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchAddressesFromBackend() async {
    var adressesToQuery = <String, int>{};
    await _walletProvider.populateWifMap(
      identifier: _coinName,
      maxValue: _addressScanPointer + _addressChunkSize,
      walletNumber: _walletNumber,
    );

    for (int i = _addressScanPointer;
        i < _addressScanPointer + _addressChunkSize;
        i++) {
      var res = await _walletProvider.getAddressFromDerivationPath(
        identifier: _coinName,
        account: _walletNumber,
        chain: i,
        address: 0,
      );
      adressesToQuery[res] = 0;
    }

    await _parseMarismaResult(
      await BackgroundSync.getNumberOfUtxosFromMarisma(
        walletName: _coinName,
        addressesToQuery: adressesToQuery,
        fromScan: true,
      ),
    );
  }

  Future<void> _parseMarismaResult(Map<String, int> result) async {
    if (result.isNotEmpty) {
      LoggerWrapper.logInfo(
        'WalletImportScan',
        'parseBackendResult',
        result.toString(),
      );
      //loop through addresses in result
      result.forEach((addr, n) async {
        //backend knows this addr
        if (n > 0) {
          await _walletProvider.addAddressFromScan(
            identifier: _coinName,
            address: addr,
            status: 'hasUtxo',
          );
        }
      });

      //keep searching in next chunk
      setState(() {
        _addressScanPointer += _addressChunkSize;
        _addressChunkSize += 5;
      });
      await _fetchAddressesFromBackend();
    } else {
      //done
      await _startScan();
    }
  }

  Future<void> _startScan() async {
    if (_scanStarted == false) {
      LoggerWrapper.logInfo(
        'WalletImportScan',
        'startScan',
        'Scan started - _backgroundNotificationsAvailable $_backgroundNotificationsAvailable',
      );
      //returns master address for hd wallet
      var masterAddr = await _walletProvider.getAddressFromDerivationPath(
        identifier: _coinName,
        account: _walletNumber,
        chain: 0,
        address: 0,
        isMaster: true,
      );

      //subscribe to hd master
      _connectionProvider!.subscribeToScriptHashes(
        _backgroundNotificationsAvailable
            ? await _walletProvider.getWalletScriptHashes(
                _coinName,
              )
            : await _walletProvider.getWalletScriptHashes(
                _coinName,
                masterAddr,
              ),
      );

      setState(() {
        _scanStarted = true;
      });
    }
  }

  //TODO rewrite to find wallet accounts and be more verbose
  //TODO test multi wallets without background notifications
}
