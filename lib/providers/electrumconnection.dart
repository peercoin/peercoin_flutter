import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:web_socket_channel/io.dart';

//connectionState schema
//"waiting"
//"online"

class ElectrumConnection with ChangeNotifier {
  static const Map<String, List> _availableServers = {
    "peercoin": ["wss://electrum.peercoinexplorer.net:50004"],
    "peercoinTestnet": ["wss://testnet-electrum.peercoinexplorer.net:50004"]
  };

  static const Map<String, double> _requiredProtocol = {
    "peercoin": 1.4,
    "peercoinTestnet": 1.4
  };

  Timer _pingTimer;
  IOWebSocketChannel _connection;
  String _connectionState;
  ActiveWallets _activeWallets;
  Map _addresses = {};
  String _coinName;
  ElectrumConnection(this._activeWallets);
  int _latestBlock;
  bool _closedIntentionally = false;
  bool _scanMode = false;

  bool init(walletName, [bool scanMode = false]) {
    if (_connection == null) {
      _coinName = walletName;
      _connectionState = "waiting";
      _closedIntentionally = false;
      _scanMode = scanMode;
      print("init server connection");
      connect();
      Stream stream = _connection.stream;

      stream.listen(
          (elem) {
            replyHandler(elem);
          },
          onError: (error) => print("error: $error"),
          onDone: () {
            cleanUpOnDone();
            print("connection done");
          });
      tryHandShake();
      startPingTimer();
      return true;
    }
    return false;
  }

  dynamic connect() {
    String initialUrl = _availableServers[_coinName]
        [_availableServers[_coinName].length - 1]; //TODO ? pick random sever ?

    try {
      _connection = IOWebSocketChannel.connect(
        initialUrl,
      );
    } catch (e) {
      print("error $e");
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

  set latestBlock(newLatest) {
    _latestBlock = newLatest;
    notifyListeners();
  }

  Map get listenedAddresses {
    return _addresses;
  }

  void closeConnection() {
    if (_connection != null && _connection.sink != null) {
      _closedIntentionally = true;
      _connection.sink.close();
    }
  }

  void cleanUpOnDone() {
    _pingTimer.cancel();
    _pingTimer = null;
    connectionState = "waiting";
    _connection = null;
    _addresses = {};
    _latestBlock = null;
    _scanMode = false;
    if (_closedIntentionally == false)
      Timer(Duration(seconds: 10),
          () => init(_coinName)); //retry if not intentional
  }

  void replyHandler(reply) {
    log("${DateTime.now().toIso8601String()} $reply");
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

  void tryHandShake() {
    sendMessage("server.version", "version");
  }

  void handleHandShake(List result) {
    double version = double.parse(result.elementAt(result.length - 1));
    if (version < _requiredProtocol[_coinName]) {
      //protocol version too low!"
      //TODO invoke try next server method
    } else {
      //we're connected and version handshake is successful
      connectionState = "connected";
      //subscribe to headers
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
    _activeWallets.updateBroadcasted(_coinName, txId, true);
  }
}

//TODO: v0.3 try to connect to another server on failed version handshake
//TODO: v0.3 get server peers and store in box ? sendMessage("server.peers.subscribe", 2);
