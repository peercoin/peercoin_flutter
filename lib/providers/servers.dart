import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/server.dart';
import 'package:peercoin/providers/encryptedbox.dart';

class Servers with ChangeNotifier {
  final EncryptedBox _encryptedBox;
  Box<Server> _serverBox;
  Servers(this._encryptedBox);

  static const Map<String, List> _seeds = {
    'peercoin': [
      'wss://electrum.peercoinexplorer.net:50004',
      'wss://allingas.peercoinexplorer.net:50004',
    ],
    'peercoinTestnet': [
      'wss://testnet-electrum.peercoinexplorer.net:50009',
      'wss://allingas.peercoinexplorer.net:50009',
    ]
  };

  Future<void> init(String coinIdentifier) async {
    print('init server provider');
    _serverBox = await Hive.openBox<Server>(
      'serverBox-$coinIdentifier',
      encryptionCipher: HiveAesCipher(await _encryptedBox.key),
    );

    //check first run
    if (_serverBox.isEmpty) {
      print('server storage is empty, initializing');

      _seeds[coinIdentifier].asMap().forEach((index, hardcodedSeedAddress) {
        var newServer = Server(
          address: hardcodedSeedAddress,
          priority: index,
          userGenerated: false,
        );
        _serverBox.add(newServer);
      });
    }

    // check if all hard coded seeds for this coin are already in db
    _seeds[coinIdentifier].forEach((hardcodedSeedAddress) {
      var res = _serverBox.values.firstWhere(
          (element) => element.getAddress == hardcodedSeedAddress,
          orElse: () => null);
      if (res == null) {
        //hard coded server not yet in storage
        print('$hardcodedSeedAddress not yet in storage');
        addServer(hardcodedSeedAddress);
      }
    });
    //check if hard coded seeds have been removed
    _serverBox.values.forEach((boxElement) {
      var res = _seeds[coinIdentifier].firstWhere(
          (element) => element == boxElement.address,
          orElse: () => null);
      if (res == null) {
        print('${boxElement.address} not existant anymore');
        removeServer(boxElement);
      }
    });
  }

  void addServer(String url, [bool userGenerated = false]) {
    final priority = _serverBox.length;
    var newServer = Server(
      address: url,
      priority: priority,
      userGenerated: userGenerated,
    );
    _serverBox.add(newServer);
  }

  void removeServer(Server server) {
    final serverMap = _serverBox.toMap();
    serverMap.forEach((key, value) {
      if (value.address == server.address) {
        _serverBox.delete(key);
      }
    });
  }

  Future<List> getServerList(String coinIdentifier) async {
    //form list
    var _availableServers = List.generate(
      _serverBox.values.length,
      (index) => '',
    );
    _serverBox.values.forEach((Server server) {
      if (server.hidden == false && server.connectable == true) {
        _availableServers.insert(server.priority, server.address);
      }
    });

    final _prunedList =
        _availableServers.where((element) => element.isNotEmpty).toList();
    print('available servers $_prunedList');

    return _prunedList;
  }

  Future<List<Server>> getServerDetailsList(String coinIdentifier) async {
    //form list
    var _availableServersDetails = <Server>[];

    _serverBox.values.forEach((Server server) {
      _availableServersDetails.add(server);
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
