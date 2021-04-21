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
      // "wss://allingas.peercoinexplorer.net:50004",
    ],
    "peercoinTestnet": [
      "wss://testnet-electrum.peercoinexplorer.net:50004",
      "wss://t2estnet-electrum.peercoinexplorer.net:50004", //TODO remove
      "wss://surenot22.net:50004", //TODO remove
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
        addServer(hardcodedSeedAddress);
      }
    });
  }

  void addServer(String url, [bool userGenerated = false]) {
    final priority = _serverBox.length;
    Server newServer = Server(address: url, priority: priority);
    if (userGenerated) newServer.setUserGenerated = true;
    _serverBox.add(newServer);
  }

  Future<List> getServerList(String coinIdentifier) async {
    //form list
    List _availableServers = List.generate(
      _serverBox.values.length,
      (index) => null,
    );
    _serverBox.values.forEach((Server server) {
      if (server.hidden == false && server.connectable == true) {
        _availableServers.insert(server.priority, server.address);
      }
    });

    final _prunedList = _availableServers.whereType<String>().toList();
    print("available servers $_prunedList");

    return _prunedList;
  }

  Future<List<Server>> getServerDetailsList(String coinIdentifier) async {
    //form list
    List<Server> _availableServersDetails = List.generate(
      _serverBox.values.length,
      (index) => null,
    );
    _serverBox.values.forEach((Server server) {
      _availableServersDetails.removeAt(server.priority);
      _availableServersDetails.insert(server.priority, server);
    });

    //sort by connectable
    _availableServersDetails.sort((a, b) {
      if (b.connectable) {
        return 1;
      }
      return -1;
    });
    //sort by priority
    _availableServersDetails.sort((a, b) => a.priority.compareTo(b.priority));

    return _availableServersDetails;
  }
}
