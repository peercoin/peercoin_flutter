import 'dart:async';

import 'package:flutter/material.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/backgroundsync.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class WalletImportScanScreen extends StatefulWidget {
  @override
  _WalletImportScanScreenState createState() => _WalletImportScanScreenState();
}

class _WalletImportScanScreenState extends State<WalletImportScanScreen> {
  bool _initial = true;
  bool _scanStarted = false;
  ElectrumConnection? _connectionProvider;
  late ActiveWallets _activeWallets;
  late String _coinName = '';
  late ElectrumConnectionState _connectionState;
  int _latestUpdate = 0;
  late Timer _timer;
  bool _reconnected = false;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      setState(() {
        _initial = false;
      });
      _coinName = ModalRoute.of(context)!.settings.arguments as String;
      _connectionProvider = Provider.of<ElectrumConnection>(context);
      _activeWallets = Provider.of<ActiveWallets>(context);
      await _activeWallets.prepareForRescan(_coinName);
      await _connectionProvider!.init(_coinName, scanMode: true);

      _timer = Timer.periodic(Duration(seconds: 7), (timer) async {
        var dueTime = _latestUpdate + 7;
        if (_connectionState == ElectrumConnectionState.waiting) {
          await _connectionProvider!.init(_coinName, scanMode: true);
        } else if (dueTime <= DateTime.now().millisecondsSinceEpoch ~/ 1000) {
          //sync notification backend
          await BackgroundSync.executeSync(fromScan: true);
          _timer.cancel();
          await Navigator.of(context).pushReplacementNamed(Routes.WalletList,
              arguments: {'fromScan': true});
        }
      });
    } else if (_connectionProvider != null) {
      _connectionState = _connectionProvider!.connectionState;

      if (_connectionState == ElectrumConnectionState.connected) {
        _latestUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        if (_scanStarted == false) {
          //returns master address for hd wallet
          var _masterAddr = await _activeWallets.getAddressFromDerivationPath(
              _coinName, 0, 0, 0, true);

          //subscribe to hd master
          _connectionProvider!.subscribeToScriptHashes(await _activeWallets
              .getWalletScriptHashes(_coinName, _masterAddr));

          setState(() {
            _scanStarted = true;
          });
        }

        if (_connectionProvider!.openReplies.isEmpty) {
          //no more replies left - check what is left to do
          if (_reconnected == false) {
            await _connectionProvider!.closeConnection();
            await Future.delayed(
              Duration(seconds: 1),
              () async {
                await _connectionProvider!.init(_coinName, scanMode: false);
                _connectionProvider!.subscribeToScriptHashes(
                    await _activeWallets.getWalletScriptHashes(_coinName));
              },
            );
            setState(() {
              _reconnected = true;
            });
          }
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

  @override
  void deactivate() async {
    await _connectionProvider!.closeConnection();
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
          ),
          SizedBox(height: 20),
          PeerButton(
            text: AppLocalizations.instance
                .translate('server_settings_alert_cancel'),
            action: () async {
              _timer.cancel();
              await Navigator.of(context)
                  .pushReplacementNamed(Routes.WalletList);
            },
          )
        ],
      ),
    );
  }
}
