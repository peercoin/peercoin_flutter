// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/available_coins.dart';
import '../providers/connection_provider.dart';
import '../providers/server_provider.dart';
import '../providers/wallet_provider.dart';
import '../tools/logger_wrapper.dart';
import 'data_source.dart';

enum ElectrumServerType { ssl, wss }

class ElectrumBackend extends DataSource {
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  var _connection;
  final WalletProvider walletProvider;
  late ElectrumServerType _serverType;
  final ServerProvider _servers;
  late String coinName;
  late String _serverUrl;
  bool _closedIntentionally = false;
  int _connectionAttempt = 0;
  late List _availableServers;
  late StreamSubscription _offlineSubscription;
  late double _requiredProtocol;
  int _resetAttempt = 1;
  final StreamController _listenerNotifier = StreamController.broadcast();

  ElectrumBackend(
    this.walletProvider,
    this._servers,
  );

  @override
  Stream listenerNotifierStream() {
    return _listenerNotifier.stream;
  }

  @override
  Future<bool> init(
    String walletName, {
    bool requestedFromWalletHome = false,
    bool fromConnectivityChangeOrLifeCycle = false,
  }) async {
    await _servers.init(walletName);
    _requiredProtocol =
        AvailableCoins.getSpecificCoin(walletName).electrumRequiredProtocol;

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      updateConnectionState = BackendConnectionState.offline;

      _offlineSubscription = Connectivity().onConnectivityChanged.listen((
        ConnectivityResult result,
      ) async {
        if (result != ConnectivityResult.none) {
          //connection re-established
          _offlineSubscription.cancel();
          await closeConnection();
          cleanUpOnDone();
          init(
            walletName,
            requestedFromWalletHome: requestedFromWalletHome,
            fromConnectivityChangeOrLifeCycle: true,
          );
        } else if (result == ConnectivityResult.none) {
          updateConnectionState = BackendConnectionState.offline;
        }
      });

      return false;
    } else if (_connection == null) {
      coinName = walletName;
      updateConnectionState = BackendConnectionState.waiting;
      LoggerWrapper.logInfo(
        'ElectrumConnection',
        'init',
        'init server connection',
      );
      await connect();

      var stream;
      if (_serverType == ElectrumServerType.ssl) {
        stream = _connection;
      } else if (_serverType == ElectrumServerType.wss) {
        stream = _connection!.stream;
      }

      if (requestedFromWalletHome == true) {
        _closedIntentionally = false;
      }

      stream.listen(
        (elem) {
          replyHandler(elem);
        },
        onError: (error) {
          LoggerWrapper.logError(
            'ElectrumConnection',
            'init',
            error.message,
          );
          _connectionAttempt++;
        },
        onDone: () {
          cleanUpOnDone();
          LoggerWrapper.logInfo(
            'ElectrumConnection',
            'init',
            'connection done',
          );
        },
      );
      tryHandShake();
      startPingTimer();

      return true;
    } else if (fromConnectivityChangeOrLifeCycle == false &&
        _closedIntentionally == false) {
      //init has been called but connection is not null yet? try again
      LoggerWrapper.logInfo(
        'ElectrumConnection',
        'init',
        'connection was not reset (yet), will try again in 1 second, reset attempt $_resetAttempt',
      );
      await Future.delayed(const Duration(seconds: 1));
      if (_resetAttempt > 3) {
        await closeConnection();
      }
      _resetAttempt++;
      await init(
        walletName,
        requestedFromWalletHome: requestedFromWalletHome,
      );
    }
    return false;
  }

  Future<void> connect() async {
    //get server list from server provider
    _availableServers = await _servers.getServerList(coinName);
    //reset attempt if attempt pointer is outside list
    if (_connectionAttempt > _availableServers.length - 1) {
      _connectionAttempt = 0;
    }
    LoggerWrapper.logInfo(
      'ElectrumConnection',
      'connect',
      'connection attempt $_connectionAttempt',
    );

    _serverUrl = _availableServers[_connectionAttempt];
    LoggerWrapper.logInfo(
      'ElectrumConnection',
      'connect',
      'connecting to $_serverUrl',
    );
    try {
      if (_serverUrl.contains('wss://')) {
        _connection = WebSocketChannel.connect(
          Uri.parse(_serverUrl),
        );
        _serverType = ElectrumServerType.wss;
      } else if (_serverUrl.contains('ssl://') && kIsWeb == false) {
        _serverType = ElectrumServerType.ssl;

        final split = _serverUrl.split(':');
        final host = split[1].replaceAll('//', '');
        final port = int.parse(split[2]);
        _connection = await SecureSocket.connect(
          host,
          port,
          timeout: const Duration(seconds: 10),
        );
      } else {
        //sockets / ssl is not available on web -> try other server
        _connectionAttempt++;
        await connect();
      }
    } catch (e) {
      _connectionAttempt++;
      LoggerWrapper.logError(
        'ElectrumConnection',
        'connect',
        e.toString(),
      );
    }
  }

  void replyReceived(String id) {
    openReplies.removeWhere((element) => element == id);
    notifyListeners();
  }

  Map get listenedAddresses {
    return addresses;
  }

  @override
  Future<void> closeConnection([bool intentional = true]) async {
    if (_connection != null) {
      _closedIntentionally = intentional;
      if (_serverType == ElectrumServerType.ssl) {
        _connection.close();
      } else if (_serverType == ElectrumServerType.wss) {
        await _connection!.sink.close();
      }
    }
    if (intentional) {
      _closedIntentionally = true;
      _connectionAttempt = 0;
      if (_reconnectTimer != null) _reconnectTimer!.cancel();
      _offlineSubscription.cancel();
    }
  }

  void cleanUpOnDone() {
    _pingTimer?.cancel();
    _pingTimer = null;
    updateConnectionState = BackendConnectionState.waiting; //setter!
    _connection = null;
    addresses = {};
    latestBlock = 0;
    paperWalletUtxos = {};
    openReplies = [];
    _resetAttempt = 1;

    if (_closedIntentionally == false) {
      _reconnectTimer = Timer(
        const Duration(seconds: 5),
        () => init(coinName),
      ); //retry if not intentional
    }
  }

  void replyHandler(reply) {
    String parsedReply;
    if (reply is Uint8List) {
      parsedReply = String.fromCharCodes(reply);
    } else {
      parsedReply = reply;
    }
    LoggerWrapper.logInfo('ElectrumConnection', 'replyHandler', parsedReply);
    var decoded = json.decode(parsedReply);
    var id = decoded['id'];
    var idString = id.toString();
    var result = decoded['result'];

    if (decoded['id'] != null) {
      LoggerWrapper.logInfo(
        'ElectrumConnection',
        'replyHandler',
        'id: $idString',
      );
      if (idString == 'version') {
        handleVersion(result);
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
      } else if (addresses[idString] != null) {
        handleAddressStatus(id, result);
      } else if (idString == 'features') {
        handleFeatures(result);
      }
    } else if (decoded['params'] != null) {
      switch (decoded['method']) {
        case 'blockchain.scripthash.subscribe':
          handleScriptHashSubscribeNotification(
            decoded['params'][0],
            decoded['params'][1],
          );
          break;
        case 'blockchain.headers.subscribe':
          handleBlock(decoded['params'][0]['height']);
          break;
      }
    }
    replyReceived(idString);
  }

  void sendMessage(String method, String? id, [List? params]) {
    openReplies.add(id);
    final String encodedMessage = json.encode(
      {'id': id, 'method': method, if (params != null) 'params': params},
    );
    if (_connection != null) {
      if (_serverType == ElectrumServerType.ssl) {
        _connection.add(encodedMessage.codeUnits);
        _connection.add('\n'.codeUnits);
      } else if (_serverType == ElectrumServerType.wss &&
          _connection.sink != null) {
        try {
          _connection.sink.add(encodedMessage);
        } catch (e) {
          LoggerWrapper.logError(
            'ElectrumConnection',
            'sendMessage',
            e.toString(),
          );
        }
      }
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
    if (version < _requiredProtocol) {
      //protocol version too low!
      closeConnection(false);
    }
  }

  void handleFeatures(Map result) {
    if (result['genesis_hash'] ==
        AvailableCoins.getSpecificCoin(coinName).genesisHash) {
      //we're connected and genesis handshake is successful
      updateConnectionState = BackendConnectionState.connected;
      //subscribe to block headers
      sendMessage('blockchain.headers.subscribe', 'blocks');
    } else {
      //wrong genesis!
      LoggerWrapper.logWarn(
        'ElectrumConnection',
        'handleFeatures',
        'wrong genesis! disconnecting.',
      );
      closeConnection(false);
    }
  }

  void handleBlock(int height) {
    latestBlock = height;
    notifyListeners();
  }

  set updateConnectionState(BackendConnectionState state) {
    connectionState = state;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    _listenerNotifier.add('notify');
  }

  void handleAddressStatus(String address, String? newStatus) async {
    var oldStatus =
        await walletProvider.getWalletAddressStatus(coinName, address);
    var hash = addresses.entries
        .firstWhereOrNull((element) => element.key == address)!;
    if (newStatus != oldStatus) {
      //emulate scripthash subscribe push
      LoggerWrapper.logInfo(
        'ElectrumConnection',
        'handleAddressStatus',
        '$address status changed! $oldStatus, $newStatus',
      );
      //handle the status update
      handleScriptHashSubscribeNotification(hash.value, newStatus);
    }
  }

  void startPingTimer() {
    _pingTimer ??= Timer.periodic(
      const Duration(minutes: 7),
      (_) {
        sendMessage('server.ping', 'ping');
      },
    );
  }

  @override
  void subscribeToScriptHashes(Map scriptHashes) {
    for (var hash in scriptHashes.entries) {
      addresses[hash.key] = hash.value;
      sendMessage('blockchain.scripthash.subscribe', hash.key, [hash.value]);
    }
    notifyListeners();
  }

  void handleScriptHashSubscribeNotification(
    String? hashId,
    String? newStatus,
  ) async {
    //got update notification for hash => get utxo
    final address = addresses.keys.firstWhere(
      (element) => addresses[element] == hashId,
      orElse: () => null,
    );
    LoggerWrapper.logInfo(
      'ElectrumConnection',
      'handleScriptHashSubscribeNotification',
      'update for $hashId',
    );
    //update status so we flag that we proccessed this update already
    await walletProvider.updateAddressStatus(coinName, address, newStatus);
    //fire listunspent to get utxo
    sendMessage(
      'blockchain.scripthash.listunspent',
      'utxo_$address',
      [hashId],
    );
  }

  @override
  void requestPaperWalletUtxos(String hashId, String address) {
    sendMessage(
      'blockchain.scripthash.listunspent',
      'paperwallet_$address',
      [hashId],
    );
  }

  void handlePaperWallet(String id, List? utxos) {
    final txAddr = id.replaceFirst('paperwallet_', '');
    paperWalletUtxos[txAddr] = utxos;
    notifyListeners();
  }

  void handleUtxo(String id, List utxos) async {
    final txAddr = id.replaceFirst('utxo_', '');
    await walletProvider.putUtxos(
      coinName,
      txAddr,
      utxos,
    );

    var walletTx = await walletProvider.getWalletTransactions(coinName);
    for (var utxo in utxos) {
      var res = walletTx.firstWhereOrNull(
        (element) => element.txid == utxo['tx_hash'],
      );
      if (res == null) {
        requestTxUpdate(utxo['tx_hash']);
      }
    }
  }

  @override
  void requestTxUpdate(String txId) {
    sendMessage(
      'blockchain.transaction.get',
      'tx_$txId',
      [txId, true],
    );
  }

  @override
  void broadcastTransaction(String txHash, String txId) {
    sendMessage(
      'blockchain.transaction.broadcast',
      'broadcast_$txId',
      [txHash],
    );
  }

  void handleTx(String id, Map? tx) async {
    var txId = id.replaceFirst('tx_', '');
    var addr = await walletProvider.getAddressForTx(coinName, txId);
    if (tx != null) {
      await walletProvider.putTx(
        identifier: coinName,
        address: addr,
        tx: tx,
      );
    } else {
      LoggerWrapper.logWarn('ElectrumConnection', 'handleTx', 'tx not found');
      //do nothing for now. if we set it to rejected, it won't be queried anymore and not be recognized if it ever confirms
    }
  }

  void handleBroadcast(String id, String result) async {
    var txId = id.replaceFirst('broadcast_', '');
    if (result == '1') {
      LoggerWrapper.logWarn(
        'ElectrumConnection',
        'handleBroadcast',
        'tx rejected by server',
      );
      await walletProvider.updateRejected(coinName, txId);
    } else if (txId != 'import') {
      await walletProvider.updateBroadcasted(coinName, txId);
    }
  }

  String get connectedServerUrl {
    if (connectionState == BackendConnectionState.connected) {
      return _serverUrl;
    }
    return '';
  }
}
