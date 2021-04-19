import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/providers/encryptedbox.dart';

class Servers with ChangeNotifier {
  EncryptedBox _encryptedBox;
  Box<Server> _serverBox;
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
    _serverBox = await Hive.openBox<Server>(
      "serverBox-$coinIdentifier",
      encryptionCipher: HiveAesCipher(await _encryptedBox.key),
    );

    //check first run
    if (_serverBox.isEmpty) {
      print("server storage is empty, initializing");

      _seeds[coinIdentifier].asMap().forEach((index, hardcodedSeedAddress) {
        Server newServer =
            Server(address: hardcodedSeedAddress, priority: index);
        _serverBox.add(newServer);
      });
    }

    // check if all hard coded seeds for this coin are already in db
    _seeds[coinIdentifier].forEach((hardcodedSeedAddress) {
      Server res = _serverBox.values.firstWhere(
          (element) => element.getAddress == hardcodedSeedAddress,
          orElse: () => null);
      if (res == null) {
        //hard coded server not yet in storage
        print("$hardcodedSeedAddress not yet in storage");
        Server newServer =
            Server(address: hardcodedSeedAddress, priority: _serverBox.length);
        _serverBox.add(newServer);
      }
    });
  }

  Future<List> getServerList(String coinIdentifier) async {
    //form list
    List _availableServers = [];
    _serverBox.values.forEach((Server server) {
      if (server.hidden == false && server.connectable == true) {
        _availableServers.insert(server.priority, server.address);
      }
    });

    print("available servers $_availableServers");

    return _availableServers;
  }

  Future<List<Server>> getServerDetailsList(String coinIdentifier) async {
    //form list
    print(_serverBox.values);
    List<Server> _availableServersDetails = List.generate(
      _serverBox.values.length,
      (index) => null,
    );
    print(_availableServersDetails);
    _serverBox.values.forEach((Server server) {
      print(server.priority);
      _availableServersDetails.removeAt(server.priority);
      _availableServersDetails.insert(server.priority, server);
    });

    print("detailed servers $_availableServersDetails");

    return _availableServersDetails;
  }
}
