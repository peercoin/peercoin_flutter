import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/server.dart';
import '../tools/logger_wrapper.dart';
import 'encrypted_box.dart';

class Servers with ChangeNotifier {
  final EncryptedBox _encryptedBox;
  late Box<Server> _serverBox;
  Servers(this._encryptedBox);

  static const Map<String, List> _seeds = {
    'peercoin': [
      'wss://electrum.peercoinexplorer.net:50004',
      'wss://allingas.peercoinexplorer.net:50004',
    ],
    'peercoinTestnet': [
      'ssl://testnet-electrum.peercoinexplorer.net:50008',
      'wss://testnet-electrum.peercoinexplorer.net:50009',
      'wss://allingas.peercoinexplorer.net:50009',
    ]
  };

  Future<void> init(String? coinIdentifier) async {
    LoggerWrapper.logInfo('Servers', 'init', 'init server provider');
    _serverBox = await Hive.openBox<Server>(
      'serverBox-$coinIdentifier',
      encryptionCipher: HiveAesCipher(await _encryptedBox.key as List<int>),
    );

    //check first run
    if (_serverBox.isEmpty) {
      LoggerWrapper.logInfo(
          'Servers', 'init', 'server storage is empty, initializing');

      _seeds[coinIdentifier!]!.asMap().forEach((index, hardcodedSeedAddress) {
        var newServer = Server(
          address: hardcodedSeedAddress,
          priority: index,
          userGenerated: false,
        );
        _serverBox.add(newServer);
      });
    }

    // check if all hard coded seeds for this coin are already in db
    for (var hardcodedSeedAddress in _seeds[coinIdentifier!]!) {
      var res = _serverBox.values.firstWhereOrNull(
          (element) => element.getAddress == hardcodedSeedAddress);
      if (res == null) {
        //hard coded server not yet in storage
        LoggerWrapper.logInfo(
          'Servers',
          'init',
          '$hardcodedSeedAddress not yet in storage',
        );
        addServer(hardcodedSeedAddress);
      }
    }
    //check if hard coded seeds have been removed
    for (var boxElement in _serverBox.values) {
      var res = _seeds[coinIdentifier]!.firstWhere(
          (element) => element == boxElement.address,
          orElse: () => null);
      if (res == null) {
        LoggerWrapper.logInfo(
          'Servers',
          'init',
          '${boxElement.address} not existant anymore',
        );
        removeServer(boxElement);
      }
    }
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
    for (var server in _serverBox.values) {
      if (server.hidden == false && server.connectable == true) {
        _availableServers.insert(server.priority, server.address);
      }
    }

    final _prunedList =
        _availableServers.where((element) => element.isNotEmpty).toList();
    LoggerWrapper.logInfo(
      'Servers',
      'getServerList',
      'available servers $_prunedList',
    );

    return _prunedList;
  }

  Future<List<Server>> getServerDetailsList(String coinIdentifier) async {
    //form list
    var _availableServersDetails = <Server>[];

    for (var server in _serverBox.values) {
      _availableServersDetails.add(server);
    }

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
