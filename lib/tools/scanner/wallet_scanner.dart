import 'package:peercoin/data_sources/electrum_scanner.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/tools/app_localizations.dart';

import '../../models/wallet_scanner_stream_reply.dart';
import '../../providers/server_provider.dart';
import '../logger_wrapper.dart';
import '../../data_sources/data_source.dart';

class WalletScanner {
  String coinName;
  int accountNumber;
  BackendType backend;
  WalletProvider walletProvider;
  ServerProvider serverProvider;

  WalletScanner({
    required this.accountNumber,
    required this.backend,
    required this.coinName,
    required this.walletProvider,
    required this.serverProvider,
  });

  Stream<WalletScannerStreamReply> startWalletScan() async* {
    LoggerWrapper.logInfo(
      'WalletScanner',
      'startWalletScan',
      'starting scan for $coinName at $accountNumber with ${backend.name}',
    );

    //Return stream of scan results
    if (backend == BackendType.electrum) {
      // init electrum
      final electrumScanner = ElectrumScanner(
        walletProvider,
        serverProvider,
      );

      if (await electrumScanner
              .init(coinName)
              .timeout(const Duration(seconds: 10)) ==
          true) {
        yield WalletScannerStreamReply(
          type: WalletScannerMessageType.scanStarted,
          message: AppLocalizations.instance.translate(
            'wallet_scanner_message_init',
            {'coin': coinName, 'account': accountNumber.toString()},
          ),
          task: (coinName, accountNumber),
        );

        try {
          final res = await queryAddressesFromElectrumBackend(electrumScanner);

          // yield from res
          for (var i = 0; i < res.length; i++) {
            yield WalletScannerStreamReply(
              type: WalletScannerMessageType.newAddressFound,
              message: res[i],
              task: (coinName, accountNumber),
            );
          }

          // yield new wallet found if addresses where found
          if (res.isNotEmpty) {
            yield WalletScannerStreamReply(
              type: WalletScannerMessageType.newWalletFound,
              message: AppLocalizations.instance.translate(
                'wallet_scanner_message_new_wallet_found',
                {
                  'coinName': coinName,
                  'accountNumber': accountNumber.toString()
                },
              ),
              task: (coinName, accountNumber),
            );
          }

          // done
          yield WalletScannerStreamReply(
            type: WalletScannerMessageType.scanFinished,
            message: AppLocalizations.instance.translate(
              'wallet_scanner_message_scan_finished',
              {
                'coinName': coinName,
                'accountNumber': accountNumber.toString(),
              },
            ),
            task: (coinName, accountNumber),
          );
        } catch (e) {
          yield WalletScannerStreamReply(
            type: WalletScannerMessageType.error,
            message: AppLocalizations.instance.translate(
              'wallet_scanner_message_scan_failed',
              {
                'coinName': coinName,
                'accountNumber': accountNumber.toString(),
                'e': e.toString(),
              },
            ),
            task: (coinName, accountNumber),
          );
        } finally {
          await electrumScanner.closeConnection(true);
        }
      } else {
        yield WalletScannerStreamReply(
          type: WalletScannerMessageType.error,
          message: AppLocalizations.instance.translate(
            'wallet_scanner_message_scan_connection_failed',
            {
              'coinName': coinName,
              'accountNumber': accountNumber.toString(),
            },
          ),
          task: (coinName, accountNumber),
        );
        await electrumScanner.closeConnection(true);
      }
    } else {
      // marisma
    }
  }

  Future<List<String>> queryAddressesFromElectrumBackend(
    ElectrumScanner electrumScanner,
  ) async {
    List<String> knownAddresses = [];

    // get master address if account number is 0
    if (accountNumber == 0) {
      final masterAddr = await walletProvider.getAddressFromDerivationPath(
        identifier: coinName,
        account: accountNumber,
        chain: 0,
        address: 0,
        isMaster: true,
      );
      // query master addr
      final masterAddrRes =
          await electrumScanner.getAddressIsKnown(masterAddr).timeout(
                const Duration(
                  seconds: 5,
                ),
              );
      LoggerWrapper.logInfo(
        'WalletScanner',
        'queryAddressesFromElectrumBackend',
        'master address $masterAddr is known: $masterAddrRes',
      );

      if (masterAddrRes == true) {
        knownAddresses.add(masterAddr);
      }
    }

    // query first 5 addresses
    for (var i = 0; i < 5; i++) {
      final addr = await walletProvider.getAddressFromDerivationPath(
        identifier: coinName,
        account: accountNumber,
        chain: i,
        address: 0,
      );
      final res = await electrumScanner.getAddressIsKnown(addr);
      LoggerWrapper.logInfo(
        'WalletScanner',
        'queryAddressesFromElectrumBackend',
        'address $addr is known: $res',
      );
      if (res == true) {
        knownAddresses.add(addr);
      }
    }

    return knownAddresses;
  }

  //TODO if wallet is opened show scan overlay till initial sync is done (use openReplies?)
}
