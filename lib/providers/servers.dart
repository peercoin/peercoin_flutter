import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/providers/encryptedbox.dart';

class Servers with ChangeNotifier {
  EncryptedBox _encryptedBox;
  Box _servers;

  Servers(this._encryptedBox);

  static const Map<String, List> _seeds = {
    "peercoin": [
      "wss://electrum.peercoinexplorer.net:50004",
      "wss://allingas.peercoinexplorer.net:50004",
    ],
    "peercoinTestnet": [
      "wss://testnet-electrum.peercoinexplorer.net:50004",
    ]
  };

  Future<void> init(String coinIdentifier) async {
    print("init server provider");
    Box _serverBox = await _encryptedBox.getGenericBox("serverBox");
    _servers = _serverBox.get(coinIdentifier);
  }

  Future<List> getServerList(String coinIdentifier) async {
    return _seeds[coinIdentifier];
  }
}
