import 'package:flutter/material.dart';
import 'package:peercoin/data_sources/data_source.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/wallet_scanner_stream_reply.dart';
import 'package:peercoin/providers/server_provider.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/scanner/wallet_scanner.dart';
import 'package:provider/provider.dart';

import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';

class AppSettingsWalletScanLandingScreen extends StatefulWidget {
  const AppSettingsWalletScanLandingScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsWalletScanLandingScreen> createState() =>
      _AppSettingsWalletScanLandingScreenState();
}

class _AppSettingsWalletScanLandingScreenState
    extends State<AppSettingsWalletScanLandingScreen> {
  bool _initial = true;
  final List<String> _logLines = [];
  final List<(String, int)> _tasks = [];
  late ServerProvider _serverProvider;
  late WalletProvider _walletProvider;

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
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _logLines.length,
              itemBuilder: (context, index) {
                return Text(_logLines[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addToLog(String text) {
    setState(() {
      _logLines.add(text);
      if (_logLines.length > 10) {
        _logLines.removeAt(0);
      }
    });
  }

  @override
  void deactivate() {
    stopScan();
    super.deactivate();
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      //populate providers
      _serverProvider = Provider.of<ServerProvider>(context, listen: false);
      _walletProvider = Provider.of<WalletProvider>(context, listen: false);
      //populate tasks
      AvailableCoins.availableCoins.forEach((key, coin) {
        _tasks.add((coin.name, 0));
      });

      //start first task
      launchScan(_tasks.first);

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void launchScan((String, int) task) {
    final (String coinName, int accountNumber) = task;

    LoggerWrapper.logInfo(
      'WalletScanner ',
      'launchScan',
      '$coinName-$accountNumber',
    );
    final scanner = WalletScanner(
      accountNumber: accountNumber,
      coinName: coinName,
      backend: BackendType.electrum,
      serverProvider: _serverProvider,
      walletProvider: _walletProvider,
    );
    scanner.startWalletScan().listen((event) {
      walletScanEventHandler(event);
    });
  }

  void walletScanEventHandler(WalletScannerStreamReply event) {
    LoggerWrapper.logInfo(
      'WalletScanEventHandler',
      event.type.name,
      event.message,
    );

    //write to log widwet
    _addToLog(
      '${event.type.name} ${event.message}',
    );

    if (event.type == WalletScannerMessageType.newWalletFound) {
      //TODO add wallet to wallet provider

      //add next task to queue
      final (currentTaskCoin, currentTaskAccountNumber) = event.task;
      setState(() {
        _tasks.add((currentTaskCoin, currentTaskAccountNumber + 1));
      });
    } else if (event.type == WalletScannerMessageType.scanFinished) {
      //remove current task at index 0
      setState(() {
        _tasks.removeAt(0);
      });
      if (_tasks.isNotEmpty) {
        //start next task
        launchScan(_tasks.first);
      } else {
        //TODO finish
      }
    }
  }

  void stopScan() {
    //TODO integrate
  }

  //TODO case for multi wallets without background notifications
}
