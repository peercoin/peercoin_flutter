import 'package:flutter/material.dart';
import 'package:peercoin/data_sources/data_source.dart';
import 'package:peercoin/providers/server_provider.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/scanner/wallet_scanner.dart';
import 'package:provider/provider.dart';

import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';
import '../../../tools/app_routes.dart';
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
          const SizedBox(height: 20),
          PeerButton(
            text: AppLocalizations.instance
                .translate('server_settings_alert_cancel'),
            action: () async {
              stopScan();
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
  void deactivate() {
    stopScan();
    super.deactivate();
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      final scanner = WalletScanner(
        accountNumber: 0,
        coinName: 'peercoinTestnet',
        backend: BackendType.electrum,
        serverProvider: Provider.of<ServerProvider>(context),
        walletProvider: Provider.of<WalletProvider>(context),
      );
      scanner.startWalletScan().listen((event) {
        LoggerWrapper.logInfo('WalletScanner', event.type.name, event.message);
      });

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void stopScan() {
    //TODO integrate
  }

  //TODO case for multi wallets without background notifications
}
