import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class WalletImportScanScreen extends StatefulWidget {
  @override
  _WalletImportScanScreenState createState() => _WalletImportScanScreenState();
}

class _WalletImportScanScreenState extends State<WalletImportScanScreen> {
  bool _initial = true;
  ElectrumConnection _connectionProvider;
  ActiveWallets _activeWallets;
  String _coinName = "";
  String _unusedAddress = "";
  Iterable _listenedAddresses;
  ElectrumConnectionState _connectionState;
  int _latestUpdate = 0;
  Timer _timer;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      setState(() {
        _initial = false;
      });
      _coinName = ModalRoute.of(context).settings.arguments as String;
      _connectionProvider = Provider.of<ElectrumConnection>(context);
      _activeWallets = Provider.of<ActiveWallets>(context);
      await _activeWallets.prepareForRescan(_coinName);
      await _activeWallets.generateUnusedAddress(_coinName);

      if (await _connectionProvider.init(_coinName, scanMode: true)) {
        _connectionProvider.subscribeToScriptHashes(
            await _activeWallets.getWalletScriptHashes(_coinName));
      }

      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        int dueTime = _latestUpdate + 5;
        if (dueTime <= DateTime.now().millisecondsSinceEpoch ~/ 1000) {
          _timer.cancel();
          await Navigator.of(context).pushReplacementNamed(Routes.WalletList);
        }
      });
    } else if (_connectionProvider != null) {
      _connectionState = _connectionProvider.connectionState;
      _unusedAddress = _activeWallets.getUnusedAddress;

      _listenedAddresses = _connectionProvider.listenedAddresses.keys;
      if (_connectionState == ElectrumConnectionState.connected) {
        if (_listenedAddresses.length == 0) {
          //listenedAddresses not populated after reconnect - resubscribe
          _connectionProvider.subscribeToScriptHashes(
              await _activeWallets.getWalletScriptHashes(_coinName));
        } else if (_listenedAddresses.contains(_unusedAddress) == false) {
          //subscribe to newly created addresses
          _connectionProvider.subscribeToScriptHashes(await _activeWallets
              .getWalletScriptHashes(_coinName, _unusedAddress));
        }
        _latestUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void deactivate() async {
    await _connectionProvider.closeConnection();
    _timer.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          AppLocalizations.instance.translate('wallet_scan_appBar_title'),
        )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(),
          SizedBox(height: 20),
          Text(
            AppLocalizations.instance.translate('wallet_scan_notice'),
          )
        ],
      ),
    );
  }
}
