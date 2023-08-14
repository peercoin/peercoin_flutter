import '../models/coin.dart';
import '../models/wallet_scanner_stream_reply.dart';
import 'logger_wrapper.dart';
import '../data_sources/data_source.dart';

class WalletScanner {
  int _chainDepthPointer = 0;
  Coin coin;
  int accountNumber;
  BackendType backend;

  WalletScanner({
    required this.accountNumber,
    required this.backend,
    required this.coin,
  });

  Stream<WalletScannerStreamReply> startScanning() async* {
    LoggerWrapper.logInfo(
      'WalletScanner',
      'start',
      'starting scan for ${coin.displayName} at $accountNumber with ${backend.name}',
    );

    //Return stream of scan results
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
