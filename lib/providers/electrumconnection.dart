import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/servers.dart';
import 'package:web_socket_channel/io.dart';

//connectionState schema
//"waiting"
//"online"

class ElectrumConnection with ChangeNotifier {
  static const Map<String, double> _requiredProtocol = {
    "peercoin": 1.4,
    "peercoinTestnet": 1.4
  };

  Timer _pingTimer;
  Timer _reconnectTimer;
  IOWebSocketChannel _connection;
  String _connectionState;
  ActiveWallets _activeWallets;
  Servers _servers;
  Map _addresses = {};
  Map<String, List> _paperWalletUtxos = {};
  String _coinName;
  int _latestBlock;
  bool _closedIntentionally = false;
  bool _scanMode = false;
  int _connectionAttempt = 0;
  List _availableServers;

  ElectrumConnection(this._activeWallets, this._servers);

  Future<bool> init(
    walletName, {
    bool scanMode = false,
    bool requestedFromWalletHome = false,
  }) async {
    if (_connection == null) {
      _coinName = walletName;
      _connectionState = "waiting";
      _scanMode = scanMode;
      print("init server connection");
      await _servers.init(walletName);
      await connect(_connectionAttempt);
      Stream stream = _connection.stream;

      if (requestedFromWalletHome == true) {
        _closedIntentionally = false;
      }

      stream.listen((elem) {
        replyHandler(elem);
      }, onError: (error) {
        print("stream error: $error");
        _connectionAttempt++;
      }, onDone: () {
        cleanUpOnDone();
        print("connection done");
      });
      tryHandShake();
      startPingTimer();

      return true;
    }
    return false;
  }

  Future<void> connect(_attempt) async {
    print("connection attempt $_attempt");
    //get server list from server provider
    _availableServers = await _servers.getServerList(_coinName);
    //reset attempt if attempt pointer is outside list
    if (_attempt > _availableServers.length - 1) {
      _connectionAttempt = 0;
    }

    String _serverUrl = _availableServers[_connectionAttempt];
    print("connecting to $_serverUrl");
    try {
      _connection = IOWebSocketChannel.connect(
        _serverUrl,
      );
    } catch (e) {
      print("connection error: $e");
    }
  }

  set connectionState(String newState) {
    _connectionState = newState;
    notifyListeners();
  }

  String get connectionState {
    return _connectionState;
  }

  int get latestBlock {
    return _latestBlock;
  }

  set latestBlock(int newLatest) {
    _latestBlock = newLatest;
    notifyListeners();
  }

  Map get listenedAddresses {
    return _addresses;
  }

  Map<String, List> get paperWalletUtxos {
    return _paperWalletUtxos;
  }

  Future<void> closeConnection([bool _intentional = true]) async {
    if (_connection != null && _connection.sink != null) {
      _closedIntentionally = _intentional;
      _connectionAttempt = 0;
      await _connection.sink.close();
    }
    if (_intentional) {
      _closedIntentionally = true;
      if (_reconnectTimer != null) _reconnectTimer.cancel();
    }
  }

  void cleanPaperWallet() {
    _paperWalletUtxos = {};
  }

  void cleanUpOnDone() {
    _pingTimer.cancel();
    _pingTimer = null;
    connectionState = "waiting"; //setter!
    _connection = null;
    _addresses = {};
    _latestBlock = null;
    _scanMode = false;
    _paperWalletUtxos = {};

    if (_closedIntentionally == false)
      _reconnectTimer = Timer(Duration(seconds: 5),
          () => init(_coinName)); //retry if not intentional
  }

  void replyHandler(reply) {
    developer.log("${DateTime.now().toIso8601String()} $reply");
    var decoded = json.decode(reply);
    var id = decoded["id"];
    String idString = id.toString();
    var result = decoded["result"];

    if (decoded["id"] != null) {
      print("replyhandler $idString");
      if (idString == "version") {
        handleHandShake(result);
      } else if (idString.startsWith("history_")) {
        handleHistory(result);
      } else if (idString.startsWith("tx_")) {
        handleTx(id, result);
      } else if (idString.startsWith("utxo_")) {
        handleUtxo(id, result);
      } else if (idString.startsWith("paperwallet_")) {
        handlePaperWallet(id, result);
      } else if (idString.startsWith("broadcast_")) {
        handleBroadcast(id, result);
      } else if (idString == "blocks") {
        handleBlock(result["height"]);
      } else if (_addresses[idString] != null) {
        handleAddressStatus(id, result);
      }
    } else if (decoded["params"] != null) {
      switch (decoded["method"]) {
        case "blockchain.scripthash.subscribe":
          handleScriptHashSubscribeNotification(
              decoded["params"][0], decoded["params"][1]);
          break;
        case "blockchain.headers.subscribe":
          handleBlock(decoded["params"][0]["height"]);
          break;
      }
    }
  }

  void sendMessage(String method, String id, [List params]) {
    if (_connection != null) {
      _connection.sink.add(
        json.encode(
          {"id": id, "method": method, if (params != null) "params": params},
        ),
      );
    }
  }

  void tryHandShake() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    sendMessage(
      "server.version",
      "version",
      ["${packageInfo.appName}-flutter-${packageInfo.version}"],
    );
  }

  void handleHandShake(List result) {
    double version = double.parse(result.elementAt(result.length - 1));
    if (version < _requiredProtocol[_coinName]) {
      //protocol version too low!
      closeConnection(false);
    } else {
      //we're connected and version handshake is successful
      connectionState = "connected";
      //subscribe to block headers
      sendMessage("blockchain.headers.subscribe", "blocks");
    }
  }

  void handleBlock(int height) {
    latestBlock = height;
  }

  void handleAddressStatus(String address, String newStatus) async {
    var oldStatus =
        await _activeWallets.getWalletAddressStatus(_coinName, address);
    if (newStatus != oldStatus) {
      //emulate scripthash subscribe push
      var hash = _addresses.entries
          .firstWhere((element) => element.key == address, orElse: () => null);
      print("status changed! $oldStatus, $newStatus");
      //handle the status update
      handleScriptHashSubscribeNotification(hash.value, newStatus);
    }
  }

  void startPingTimer() {
    if (_pingTimer == null) {
      _pingTimer = Timer.periodic(
        Duration(minutes: 8),
        (_) {
          sendMessage("server.ping", "ping");
        },
      );
    }
  }

  void subscribeToScriptHashes(Map addresses) {
    addresses.entries.forEach((hash) {
      _addresses[hash.key] = hash.value;
      sendMessage("blockchain.scripthash.subscribe", hash.key, [hash.value]);
    });
  }

  void handleScriptHashSubscribeNotification(
      String hashId, String newStatus) async {
    //got update notification for hash => get utxo
    final address = _addresses.keys.firstWhere(
        (element) => _addresses[element] == hashId,
        orElse: () => null);
    print("update for $hashId");
    //update status so we flag that we proccessed this update already
    await _activeWallets.updateAddressStatus(_coinName, address, newStatus);
    //fire listunspent to get utxo
    sendMessage(
      "blockchain.scripthash.listunspent",
      "utxo_$address",
      [hashId],
    );
  }

  void requestPaperWalletUtxos(String hashId, String address) {
    sendMessage(
      "blockchain.scripthash.listunspent",
      "paperwallet_$address",
      [hashId],
    );
  }

  void handlePaperWallet(String id, List utxos) {
    final txAddr = id.replaceFirst("paperwallet_", "");
    _paperWalletUtxos[txAddr] = utxos;
    notifyListeners();
  }

  void handleUtxo(String id, List utxos) async {
    final txAddr = id.replaceFirst("utxo_", "");
    await _activeWallets.putUtxos(
      _coinName,
      txAddr,
      utxos,
    );
    //fire get_history
    sendMessage(
      "blockchain.scripthash.get_history",
      "history_$txAddr",
      [_addresses[txAddr]],
    );
  }

  void handleHistory(List result) async {
    result.forEach((historyTx) {
      var txId = historyTx["tx_hash"];
      sendMessage(
        "blockchain.transaction.get",
        "tx_$txId",
        [txId, true],
      );
    });
  }

  void requestTxUpdate(String txId) {
    sendMessage(
      "blockchain.transaction.get",
      "tx_$txId",
      [txId, true],
    );
  }

  void broadcastTransaction(String txHash, String txId) {
    sendMessage(
      "blockchain.transaction.broadcast",
      "broadcast_$txId",
      [txHash],
    );
  }

  void handleTx(String id, Map tx) async {
    String txId = id.replaceFirst("tx_", "");
    String addr = await _activeWallets.getAddressForTx(_coinName, txId);
    if (tx != null) {
      await _activeWallets.putTx(_coinName, addr, tx, _scanMode);
    }
  }

  void handleBroadcast(String id, String result) {
    String txId = id.replaceFirst("broadcast_", "");
    if (txId != "import") {
      _activeWallets.updateBroadcasted(_coinName, txId, true);
    }
  }
}
