import '../tools/logger_wrapper.dart';
import 'data_source.dart';

enum WalletScanMode { seed, singleWallet, singleCoin }

class WalletScanner {
  int _depthPointer = 1;
  int _maxChainDepth = 5;
  int _maxAddressDepth = 0; //no address depth scan for now
  Map<String, int> _queryDepth = {'account': 0, 'chain': 0, 'address': 0};

  String walletName;
  WalletScanMode scanMode;
  DataSource backend;

  WalletScanner({
    required this.walletName,
    required this.scanMode,
    required this.backend,
  });

  // void hold() {
  //     if (newStatus == null) {
  //       await subscribeNextDerivedAddress(); //TODO move this logic out of the connection provider, it has no real business here
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
