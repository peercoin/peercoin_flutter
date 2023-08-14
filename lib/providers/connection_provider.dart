import 'package:flutter/foundation.dart';

import '../data_sources/data_source.dart';

enum BackendConnectionState { waiting, connected, offline }

class ConnectionProvider with ChangeNotifier {
  late DataSource _dataSource;

  // Method to switch the data source.
  void setDataSource(DataSource newDataSource) {
    _dataSource = newDataSource;
    _dataSource.listenerNotifierStream().listen((event) {
      notifyListeners();
    });
  }

  Future<bool> init(
    walletName, {
    bool scanMode = false,
    bool requestedFromWalletHome = false,
    bool fromConnectivityChangeOrLifeCycle = false,
  }) async {
    return await _dataSource.init(
      walletName,
      requestedFromWalletHome: requestedFromWalletHome,
      fromConnectivityChangeOrLifeCycle: fromConnectivityChangeOrLifeCycle,
    );
  }

  BackendConnectionState get connectionState => _dataSource.connectionState;

  Future<void> closeConnection([bool intentional = true]) async {
    await _dataSource.closeConnection(intentional);
  }

  void subscribeToScriptHashes(Map scriptHashes) {
    _dataSource.subscribeToScriptHashes(scriptHashes);
  }

  Map<String, List?> get paperWalletUtxos => _dataSource.paperWalletUtxos;

  void cleanPaperWallet() {
    _dataSource.paperWalletUtxos = {};
  }

  void requestPaperWalletUtxos(String hashId, String address) {
    _dataSource.requestPaperWalletUtxos(hashId, address);
  }

  void broadcastTransaction(String txHash, String txId) {
    _dataSource.broadcastTransaction(txHash, txId);
  }

  List get openReplies {
    return _dataSource.openReplies;
  }

  Map get listenedAddresses {
    return _dataSource.addresses;
  }

  int get latestBlock {
    return _dataSource.latestBlock;
  }

  void requestTxUpdate(String txId) {
    _dataSource.requestTxUpdate(txId);
  }
}
