import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:peercoin/models/coinwallet.dart';

class EncryptedBox with ChangeNotifier {
  Map<String, Box> cryptoBox = {};
  Uint8List encryptionKey;

  Future<Uint8List> get key async {
    if (encryptionKey == null) {
      final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
      var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
      if (!containsEncryptionKey) {
        var key = Hive.generateSecureKey();
        await secureStorage.write(key: 'key', value: base64UrlEncode(key));
      }
      encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));
    }
    return encryptionKey;
  }

  Future<Box> getGenericBox(String name) async {
    cryptoBox[name] = await Hive.openBox(
      name,
      encryptionCipher: HiveAesCipher(await key),
    );
    return cryptoBox[name];
  }

  Future<Box> getWalletBox() async {
    return await Hive.openBox<CoinWallet>(
      "wallets",
      encryptionCipher: HiveAesCipher(await key),
    );
  }
}
