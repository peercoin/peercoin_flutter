import 'package:peercoin/data_sources/electrum_scanner.dart';
import 'package:peercoin/providers/wallet_provider.dart';

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

      if (await electrumScanner.init(coinName) == true) {
        yield WalletScannerStreamReply(
          type: WalletScannerMessageType.scanStarted,
          message: 'scan initialized for $coinName at $accountNumber',
        );

        try {
          final res = await queryAddressesFromElectrumBackend(electrumScanner);

          // yield from res
          for (var i = 0; i < res.length; i++) {
            yield WalletScannerStreamReply(
              type: WalletScannerMessageType.newAddressFound,
              message: res[i],
            );
          }

          // done
          yield WalletScannerStreamReply(
            type: WalletScannerMessageType.scanFinished,
            message: 'scan finished for $coinName at $accountNumber',
          );
        } catch (e) {
          yield WalletScannerStreamReply(
            type: WalletScannerMessageType.error,
            message: 'scan failed for $coinName at $accountNumber ($e))',
          );
        } finally {
          await electrumScanner.closeConnection(true);
        }
      }
    } else {
      // marisma
    }
  }

  Future<List<String>> queryAddressesFromElectrumBackend(
    ElectrumScanner electrumScanner,
  ) async {
    List<String> knownAddresses = [];

    // get master address
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

  // void hold() {
  //     if (newStatus == null) {
  //       await subscribeNextDerivedAddress();
  //     } else {
  //       //increase depth because we found one != null
  //       if (_depthPointer == 1) {
  //         //chain pointer
  //         _maxChainDepth++;
  //       } else if (_depthPointer == 2) {
  //         //address pointer
  //         _maxAddressDepth++;
  //       }
  //       LoggerWrapper.logInfo(
  //         'ElectrumConnection',
  //         'handleAddressStatus',
  //         'writing $address to wallet',
  //       );
  //       //saving to wallet
  //       if (oldStatus == 'hasUtxo') {
  //         sendMessage(
  //           'blockchain.scripthash.listunspent',
  //           'utxo_$address',
  //           [hash.value],
  //         );
  //       } else {
  //         _walletProvider.addAddressFromScan(
  //           identifier: _coinName,
  //           address: address,
  //           status: newStatus,
  //         );
  //       }
  //       //try next
  //       await subscribeNextDerivedAddress();
  //     }

  // }
  // Future<void> subscribeNextDerivedAddress() async {
  //   var currentPointer = _queryDepth.keys.toList()[_depthPointer];

  //   if (_depthPointer == 1 && _queryDepth[currentPointer]! < _maxChainDepth ||
  //       _depthPointer == 2 && _queryDepth[currentPointer]! < _maxAddressDepth) {
  //     LoggerWrapper.logInfo(
  //       'ElectrumConnection',
  //       'subscribeNextDerivedAddress',
  //       '$_queryDepth',
  //     );

  //     var nextAddr = await _walletProvider.getAddressFromDerivationPath(
  //       identifier: _coinName,
  //       account: _queryDepth['account']!,
  //       chain: _queryDepth['chain']!,
  //       address: _queryDepth['address']!,
  //     );

  //     LoggerWrapper.logInfo(
  //       'ElectrumConnection',
  //       'subscribeNextDerivedAddress',
  //       '$nextAddr',
  //     );

  //     subscribeToScriptHashes(
  //       await _walletProvider.getWalletScriptHashes(_coinName, nextAddr),
  //     );

  //     var number = _queryDepth[currentPointer] as int;
  //     _queryDepth[currentPointer] = number + 1;
  //   } else if (_depthPointer < _queryDepth.keys.length - 1) {
  //     LoggerWrapper.logInfo(
  //       'ElectrumConnection',
  //       'subscribeNextDerivedAddress',
  //       'move pointer',
  //     );
  //     _queryDepth[currentPointer] = 0;
  //     _depthPointer++;
  //     await subscribeNextDerivedAddress();
  //   }
  // }
}