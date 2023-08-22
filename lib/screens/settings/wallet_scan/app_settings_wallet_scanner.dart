import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peercoin/data_sources/data_source.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/wallet_scanner_stream_reply.dart';
import 'package:peercoin/providers/server_provider.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/scanner/wallet_scanner.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:provider/provider.dart';

import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';

class AppSettingsWalletScanner extends StatefulWidget {
  const AppSettingsWalletScanner({Key? key}) : super(key: key);

  @override
  State<AppSettingsWalletScanner> createState() =>
      _AppSettingsWalletScannerState();
}

class _AppSettingsWalletScannerState extends State<AppSettingsWalletScanner> {
  bool _initial = true;
  bool _scanInProgress = true;
  int _nOfWalletsFound = 0;
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
            'wallet_scan',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _logLines.length,
                itemBuilder: (context, index) {
                  return Text(
                    _logLines[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily:
                          'Courier', // Monospace font for that traditional log appearance
                      letterSpacing:
                          0.5, // Slight letter spacing for better readability
                    ),
                  );
                },
              ),
            ),
          ),
          if (_scanInProgress == false)
            Flexible(
              child: Column(
                children: [
                  Text(
                    AppLocalizations.instance.translate(
                      'wallet_scan_finished',
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _nOfWalletsFound > 0
                      ? Text(
                          AppLocalizations.instance.translate(
                            'wallet_scan_n_new_found',
                            {
                              'n': _nOfWalletsFound.toString(),
                            },
                          ),
                        )
                      : Text(
                          AppLocalizations.instance.translate(
                            'wallet_scan_no_new_found',
                          ),
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  PeerButtonBorder(
                    text: AppLocalizations.instance.translate(
                      'wallet_scan_close',
                    ),
                    action: Navigator.of(context).pop,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      context.loaderOverlay.show();
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
      'AppSettingsWalletScanner',
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
      'AppSettingsWalletScanner',
      event.type.name,
      event.message,
    );

    //translate log entry for newAddressFound
    if (event.type == WalletScannerMessageType.newAddressFound) {
      _addToLog(
        '${AppLocalizations.instance.translate('wallet_scanner_message_${event.type.name}')}: ${event.message}',
      );
    } else {
      _addToLog(
        '${event.type.name}: ${event.message}',
      );
    }

    if (event.type == WalletScannerMessageType.newWalletFound) {
      final (currentTaskCoin, currentTaskAccountNumber) = event.task;
      final walletName = '${currentTaskCoin}_$currentTaskAccountNumber';

      if (_walletProvider.availableWalletKeys.contains(walletName) ||
          _walletProvider.availableWalletKeys.contains(currentTaskCoin)) {
        //second condition is backward compatabilty for old wallets without trailing number
        //wallet already exists
        LoggerWrapper.logInfo(
          'AppSettingsWalletScanner',
          'walletScanEventHandler',
          'Wallet already exists: $walletName, skipping',
        );

        _addToLog(
          AppLocalizations.instance.translate(
            'wallet_scan_wallet_already_exists',
            {'walletName': walletName},
          ),
        );
      } else {
        //add wallet to wallet provider
        final coin = AvailableCoins.getSpecificCoin(currentTaskCoin);
        String title = coin.displayName;
        if (currentTaskAccountNumber > 0) {
          title = '$title ${currentTaskAccountNumber + 1}';
        }

        try {
          _walletProvider.addWallet(
            name: walletName,
            title: title,
            letterCode: coin.letterCode,
          );
          _addToLog(
            AppLocalizations.instance.translate(
              'wallet_scan_create_success',
              {'title': title},
            ),
          );

          setState(() {
            _nOfWalletsFound++;
          });
        } catch (e) {
          LoggerWrapper.logError(
            'AppSettingsWalletScanner',
            'walletScanEventHandler',
            e.toString(),
          );
          _addToLog(
            AppLocalizations.instance.translate(
              'wallet_scan_create_error',
              {'error': e.toString()},
            ),
          );

          _endScan();
        }
      }

      //add next task to queue
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
        LoggerWrapper.logInfo(
          'AppSettingsWalletScanner',
          'walletScanEventHandler',
          'No more tasks, scan finished',
        );
        _addToLog(
          AppLocalizations.instance.translate(
            'wallet_scanning_finished',
          ),
        );

        _endScan();
      }
    } else if (event.type == WalletScannerMessageType.error) {
      _endScan();
    }
  }

  void _addToLog(String text) {
    setState(() {
      _logLines.add(text);
    });
  }

  void _endScan() {
    setState(() {
      _scanInProgress = false;
    });
    context.loaderOverlay.hide();
  }
}
