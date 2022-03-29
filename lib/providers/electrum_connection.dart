import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:package_info/package_info.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/providers/active_wallets.dart';
import 'package:peercoin/providers/servers.dart';
import 'package:web_socket_channel/io.dart';

enum ElectrumConnectionState { waiting, connected, offline }

class ElectrumConnection with ChangeNotifier {
  static const Map<String, double> _requiredProtocol = {
    'peercoin': 1.4,
    'peercoinTestnet': 1.4
  };

  Timer? _pingTimer;
  Timer? _reconnectTimer;
  IOWebSocketChannel? _connection;
  final ActiveWallets _activeWallets;
  ElectrumConnectionState _connectionState = ElectrumConnectionState.waiting;
  final Servers _servers;
  Map _addresses = {};
  Map<String, List?> _paperWalletUtxos = {};
  late String _coinName;
  int? _latestBlock;
  late String _serverUrl;
  bool _closedIntentionally = false;
  bool _scanMode = false;
  int _connectionAttempt = 0;
  late List _availableServers;
  late StreamSubscription _offlineSubscription;
  int _depthPointer = 1;
  int _maxChainDepth = 5;
  int _maxAddressDepth = 0; //no address depth scan for now
  Map<String, int> _queryDepth = {'account': 0, 'chain': 0, 'address': 0};
  List _openReplies = [];

  ElectrumConnection(this._activeWallets, this._servers);

  Future<bool> init(
    walletName, {
    bool scanMode = false,
    bool requestedFromWalletHome = false,
  }) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      connectionState = ElectrumConnectionState.offline;

      _offlineSubscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          //connection re-established
          _offlineSubscription.cancel();
          _connection = null;
          init(
            walletName,
            scanMode: scanMode,
            requestedFromWalletHome: requestedFromWalletHome,
          );
        } else if (result == ConnectivityResult.none) {
          connectionState = ElectrumConnectionState.offline;
        }
      });

      return false;
    } else if (_connection == null) {
      _coinName = walletName;
      connectionState = ElectrumConnectionState.waiting;
      _scanMode = scanMode;
      FlutterLogs.logInfo(
        'ElectrumConnection',
        'init',
        'init server connection',
      );
      await _servers.init(walletName);
      await connect();
      var stream = _connection!.stream;

      if (requestedFromWalletHome == true) {
        _closedIntentionally = false;
      }

      stream.listen((elem) {
        replyHandler(elem);
      }, onError: (error) {
        FlutterLogs.logError(
          'ElectrumConnection',
          'init',
          error.message,
        );
        _connectionAttempt++;
      }, onDone: () {
        cleanUpOnDone();
        FlutterLogs.logInfo('ElectrumConnection', 'init', 'connection done');
      });
      tryHandShake();
      startPingTimer();

      return true;
    }
    return false;
  }

  Future<void> connect() async {
    //get server list from server provider
    _availableServers = await _servers.getServerList(_coinName);
    //reset attempt if attempt pointer is outside list
    if (_connectionAttempt > _availableServers.length - 1) {
      _connectionAttempt = 0;
    }
    FlutterLogs.logInfo(
      'ElectrumConnection',
      'connect',
      'connection attempt $_connectionAttempt',
    );

    _serverUrl = _availableServers[_connectionAttempt];
    FlutterLogs.logInfo(
      'ElectrumConnection',
      'connect',
      'connecting to $_serverUrl',
    );

    try {
      _connection = IOWebSocketChannel.connect(
        _serverUrl,
      );
    } catch (e) {
      _connectionAttempt++;
      FlutterLogs.logError(
        'ElectrumConnection',
        'connect',
        e.toString(),
      );
    }
  }

  set connectionState(ElectrumConnectionState newState) {
    _connectionState = newState;
    notifyListeners();
  }

  ElectrumConnectionState get connectionState {
    return _connectionState;
  }

  int get latestBlock {
    return _latestBlock ?? 0;
  }

  set latestBlock(int newLatest) {
    _latestBlock = newLatest;
    notifyListeners();
  }

  List get openReplies {
    return _openReplies;
  }

  void replyReceived(String id) {
    _openReplies.removeWhere((element) => element == id);
    notifyListeners();
  }

  Map get listenedAddresses {
    return _addresses;
  }

  Map<String, List?> get paperWalletUtxos {
    return _paperWalletUtxos;
  }

  Future<void> closeConnection([bool _intentional = true]) async {
    if (_connection != null) {
      _closedIntentionally = _intentional;
      await _connection!.sink.close();
    }
    if (_intentional) {
      _closedIntentionally = true;
      _connectionAttempt = 0;
      if (_reconnectTimer != null) _reconnectTimer!.cancel();
    }
  }

  void cleanPaperWallet() {
    _paperWalletUtxos = {};
  }

  void cleanUpOnDone() {
    _pingTimer?.cancel();
    _pingTimer = null;
    connectionState = ElectrumConnectionState.waiting; //setter!
    _connection = null;
    _addresses = {};
    _latestBlock = null;
    _scanMode = false;
    _paperWalletUtxos = {};
    _openReplies = [];
    _queryDepth = {'account': 0, 'chain': 0, 'address': 0};
    _maxChainDepth = 5;
    _maxAddressDepth = 0; //no address depth scan for now
    _depthPointer = 1;

    if (_closedIntentionally == false) {
      _reconnectTimer = Timer(Duration(seconds: 5),
          () => init(_coinName)); //retry if not intentional
    }
  }

  @override
  void dispose() {
    _offlineSubscription.cancel();
    super.dispose();
  }

  void replyHandler(reply) {
    FlutterLogs.logInfo('ElectrumConnection', 'replyHandler', reply);
    var decoded = json.decode(reply);
    var id = decoded['id'];
    var idString = id.toString();
    var result = decoded['result'];

    if (decoded['id'] != null) {
      FlutterLogs.logInfo(
        'ElectrumConnection',
        'replyHandler',
        'id: $idString',
      );
      if (idString == 'version') {
        handleVersion(result);
      } else if (idString.startsWith('history_')) {
        handleHistory(result);
      } else if (idString.startsWith('tx_')) {
        handleTx(id, result);
      } else if (idString.startsWith('utxo_')) {
        handleUtxo(id, result);
      } else if (idString.startsWith('paperwallet_')) {
        handlePaperWallet(id, result);
      } else if (idString.startsWith('broadcast_')) {
        handleBroadcast(id, result ?? decoded['error']['code'].toString());
      } else if (idString == 'blocks') {
        handleBlock(result['height']);
      } else if (_addresses[idString] != null) {
        handleAddressStatus(id, result);
      } else if (idString == 'features') {
        handleFeatures(result);
      }
    } else if (decoded['params'] != null) {
      switch (decoded['method']) {
        case 'blockchain.scripthash.subscribe':
          handleScriptHashSubscribeNotification(
              decoded['params'][0], decoded['params'][1]);
          break;
        case 'blockchain.headers.subscribe':
          handleBlock(decoded['params'][0]['height']);
          break;
      }
    }
    replyReceived(idString);
  }

  void sendMessage(String method, String? id, [List? params]) {
    _openReplies.add(id);
    if (_connection != null) {
      _connection!.sink.add(
        json.encode(
          {'id': id, 'method': method, if (params != null) 'params': params},
        ),
      );
    }
  }

  void tryHandShake() async {
    var packageInfo = await PackageInfo.fromPlatform();
    sendMessage(
      'server.version',
      'version',
      ['${packageInfo.appName}-flutter-${packageInfo.version}'],
    );
    sendMessage('server.features', 'features');
  }

  void handleVersion(List result) {
    var version = double.parse(result.elementAt(result.length - 1));
    if (version < _requiredProtocol[_coinName]!) {
      //protocol version too low!
      closeConnection(false);
    }
  }

  void handleFeatures(Map result) {
    if (result['genesis_hash'] ==
        AvailableCoins().getSpecificCoin(_coinName).genesisHash) {
      //we're connected and genesis handshake is successful
      connectionState = ElectrumConnectionState.connected;
      //subscribe to block headers
      sendMessage('blockchain.headers.subscribe', 'blocks');
    } else {
      //wrong genesis!
      FlutterLogs.logWarn(
        'ElectrumConnection',
        'handleFeatures',
        'wrong genesis! disconnecting.',
      );
      closeConnection(false);
    }
  }

  void handleBlock(int height) {
    latestBlock = height;
  }

  void handleAddressStatus(String address, String? newStatus) async {
    var oldStatus =
        await _activeWallets.getWalletAddressStatus(_coinName, address);
    if (newStatus != oldStatus) {
      //emulate scripthash subscribe push
      var hash = _addresses.entries
          .firstWhereOrNull((element) => element.key == address)!;
      FlutterLogs.logInfo(
        'ElectrumConnection',
        'handleAddressStatus',
        'status changed! $oldStatus, $newStatus',
      );
      //handle the status update
      handleScriptHashSubscribeNotification(hash.value, newStatus);
    }
    if (_scanMode == true) {
      if (newStatus == null) {
        await subscribeNextDerivedAddress();
      } else {
        //increase depth because we found one != null
        if (_depthPointer == 1) {
          //chain pointer
          _maxChainDepth++;
        } else if (_depthPointer == 2) {
          //address pointer
          _maxAddressDepth++;
        }
        FlutterLogs.logInfo(
          'ElectrumConnection',
          'handleAddressStatus',
          'writing $address to wallet',
        );
        //saving to wallet
        _activeWallets.addAddressFromScan(_coinName, address);
        //try next
        await subscribeNextDerivedAddress();
      }
    }
  }

  Future<void> subscribeNextDerivedAddress() async {
    var currentPointer = _queryDepth.keys.toList()[_depthPointer];

    if (_depthPointer == 1 && _queryDepth[currentPointer]! < _maxChainDepth ||
        _depthPointer == 2 && _queryDepth[currentPointer]! < _maxAddressDepth) {
      FlutterLogs.logInfo(
        'ElectrumConnection',
        'subscribeNextDerivedAddress',
        '$_queryDepth',
      );

      var _nextAddr = await _activeWallets.getAddressFromDerivationPath(
        _coinName,
        _queryDepth['account']!,
        _queryDepth['chain']!,
        _queryDepth['address']!,
      );

      FlutterLogs.logInfo(
        'ElectrumConnection',
        'subscribeNextDerivedAddress',
        '$_nextAddr',
      );

      subscribeToScriptHashes(
        await _activeWallets.getWalletScriptHashes(_coinName, _nextAddr),
      );

      var _number = _queryDepth[currentPointer] as int;
      _queryDepth[currentPointer] = _number + 1;
    } else if (_depthPointer < _queryDepth.keys.length - 1) {
      FlutterLogs.logInfo(
        'ElectrumConnection',
        'subscribeNextDerivedAddress',
        'move pointer',
      );
      _queryDepth[currentPointer] = 0;
      _depthPointer++;
      await subscribeNextDerivedAddress();
    }
  }

  void startPingTimer() {
    _pingTimer ??= Timer.periodic(
      Duration(minutes: 7),
      (_) {
        sendMessage('server.ping', 'ping');
      },
    );
  }

  void subscribeToScriptHashes(Map addresses) {
    addresses.entries.forEach((hash) {
      _addresses[hash.key] = hash.value;
      sendMessage('blockchain.scripthash.subscribe', hash.key, [hash.value]);
    });
  }

  void handleScriptHashSubscribeNotification(
      String? hashId, String? newStatus) async {
    //got update notification for hash => get utxo
    final address = _addresses.keys.firstWhere(
        (element) => _addresses[element] == hashId,
        orElse: () => null);
    FlutterLogs.logInfo(
      'ElectrumConnection',
      'handleScriptHashSubscribeNotification',
      'update for $hashId',
    );
    //update status so we flag that we proccessed this update already
    await _activeWallets.updateAddressStatus(_coinName, address, newStatus);
    //fire listunspent to get utxo
    sendMessage(
      'blockchain.scripthash.listunspent',
      'utxo_$address',
      [hashId],
    );
  }

  void requestPaperWalletUtxos(String hashId, String address) {
    sendMessage(
      'blockchain.scripthash.listunspent',
      'paperwallet_$address',
      [hashId],
    );
  }

  void handlePaperWallet(String id, List? utxos) {
    final txAddr = id.replaceFirst('paperwallet_', '');
    _paperWalletUtxos[txAddr] = utxos;
    notifyListeners();
  }

  void handleUtxo(String id, List utxos) async {
    final txAddr = id.replaceFirst('utxo_', '');
    await _activeWallets.putUtxos(
      _coinName,
      txAddr,
      utxos,
    );
    //fire get_history
    sendMessage(
      'blockchain.scripthash.get_history',
      'history_$txAddr',
      [_addresses[txAddr]],
    );
  }

  void handleHistory(List result) async {
    result.forEach((historyTx) {
      var txId = historyTx['tx_hash'];
      sendMessage(
        'blockchain.transaction.get',
        'tx_$txId',
        [txId, true],
      );
    });
  }

  void requestTxUpdate(String txId) {
    sendMessage(
      'blockchain.transaction.get',
      'tx_$txId',
      [txId, true],
    );
  }

  void broadcastTransaction(String txHash, String txId) {
    sendMessage(
      'blockchain.transaction.broadcast',
      'broadcast_$txId',
      [txHash],
    );
  }

  void handleTx(String id, Map? tx) async {
    var txId = id.replaceFirst('tx_', '');
    var addr = await _activeWallets.getAddressForTx(_coinName, txId);
    if (tx != null) {
      await _activeWallets.putTx(_coinName, addr, tx, _scanMode);
    } else {
      FlutterLogs.logWarn('ElectrumConnection', 'handleTx', 'tx not found');
      //TODO figure out what to do in that case ...
      //if we set it to rejected, it won't be queried anymore and not be recognized if it ever confirms
    }
  }

  void handleBroadcast(String id, String result) async {
    var txId = id.replaceFirst('broadcast_', '');
    if (result == '1') {
      FlutterLogs.logWarn(
        'ElectrumConnection',
        'handleBroadcast',
        'tx rejected by server',
      );
      await _activeWallets.updateRejected(_coinName, txId, true);
    } else if (txId != 'import') {
      await _activeWallets.updateBroadcasted(_coinName, txId, true);
    }
  }

  String get connectedServerUrl {
    if (_connectionState == ElectrumConnectionState.connected) {
      return _serverUrl;
    }
    return '';
  }
}
