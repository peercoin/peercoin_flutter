import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/providers/encryptedbox.dart';

class Servers with ChangeNotifier {
  EncryptedBox _encryptedBox;
  List _serverStorage;
  Box _serverBox;
  Servers(this._encryptedBox);

  static const Map<String, List> _seeds = {
    "peercoin": [
      "wss://electrum.peercoinexplorer.net:50004",
      "wss://allingas.peercoinexplorer.net:50004",
    ],
    "peercoinTestnet": [
      "wss://testnet-electrum.peercoinexplorer.net:50004",
      "wss://t2estnet-electrum.peercoinexplorer.net:50004",
      "wss://surenot.net:50004",
    ]
  };

  Future<void> init(String coinIdentifier) async {
    print("init server provider");
    _serverBox = await _encryptedBox.getGenericBox("serverBox");
    _serverStorage = _serverBox.get(coinIdentifier);

    if (_serverStorage == null) {
      _serverBox.put(coinIdentifier, []);
      _serverStorage = _serverBox.get(coinIdentifier);
    }

    //check first run
    if (_serverStorage.isEmpty) {
      print("server storage is empty, initializing");

      _seeds[coinIdentifier].asMap().forEach((index, hardcodedSeedAddress) {
        Server newServer =
            Server(address: hardcodedSeedAddress, priority: index);
        _serverStorage.add(newServer);
      });
    }

    // check if all hard coded seeds for this coin are already in db
    _seeds[coinIdentifier].forEach((hardcodedSeedAddress) {
      Server res = _serverStorage.firstWhere(
          (element) => element.getAddress == hardcodedSeedAddress,
          orElse: () => null);
      if (res == null) {
        //hard coded server not yet in storage
        print("$hardcodedSeedAddress not yet in storage");
        Server newServer = Server(
            address: hardcodedSeedAddress, priority: _serverStorage.length);
        _serverStorage.add(newServer);
      }
    });
  }

  Future<List> getServerList(String coinIdentifier) async {
    //form list
    List _availableServers = [];
    _serverStorage.forEach((element) {
      if (element.hidden == false && element.connectable == true) {
        _availableServers.insert(element.priority, element.address);
      }
    });

    print("available servers $_availableServers");

    return _availableServers;
  }

  Future<List<Server>> getServerDetailsList(String coinIdentifier) async {
    //form list
    List<Server> _availableServersDetails = [];
    _serverStorage.forEach((element) {
      print(element.priority);
      _availableServersDetails.insert(element.priority, element);
    });

    print("available servers $_availableServersDetails");

    return _availableServersDetails;
  }
}
