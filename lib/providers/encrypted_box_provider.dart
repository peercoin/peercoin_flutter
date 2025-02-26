import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/hive/coin_wallet.dart';
import '../models/hive/server.dart';

class EncryptedBoxProvider with ChangeNotifier {
  final Map<String, Box> _cryptoBox = {};
  Uint8List? _encryptionKey;
  String? _passCode;
  int _failedAuths = 0;
  int _failedAuthAttempts = 0;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Uint8List?> get key async {
    if (_encryptionKey == null) {
      var encryptionKeyInStorage = await _secureStorage.read(key: 'key');
      if (encryptionKeyInStorage == null) {
        var key = Hive.generateSecureKey();
        await _secureStorage.write(key: 'key', value: base64UrlEncode(key));
      }
      _encryptionKey = base64Url.decode(
        (await _secureStorage.read(key: 'key') as String),
      );
    }
    return _encryptionKey;
  }

  Future<String?> get passCode async {
    _passCode ??= await _secureStorage.read(key: 'passCode');
    return _passCode;
  }

  Future<bool> setPassCode(String passCode) async {
    await _secureStorage.write(key: 'passCode', value: passCode);
    _passCode = passCode;
    return true;
  }

  Future<int> get failedAuths async {
    if (_failedAuths == 0) {
      final result = await _secureStorage.read(key: 'failedAuths');
      if (result == null) {
        _failedAuths = 0;
      } else {
        _failedAuths = int.parse(result);
      }
    }
    return _failedAuths;
  }

  Future<void> setFailedAuths(int newInt) async {
    await _secureStorage.write(key: 'failedAuths', value: newInt.toString());
    _failedAuths = newInt;
  }

  Future<int> get failedAuthAttempts async {
    if (_failedAuthAttempts == 0) {
      final result = await _secureStorage.read(key: 'failedAuthAttempts');
      if (result == null) {
        _failedAuthAttempts = 0;
      } else {
        _failedAuthAttempts = int.parse(result);
      }
    }
    return _failedAuthAttempts;
  }

  Future<void> setFailedAuthAttempts(int newInt) async {
    await _secureStorage.write(
      key: 'failedAuthAttempts',
      value: newInt.toString(),
    );
    _failedAuthAttempts = newInt;
  }

  Future<Box?> getGenericBox(String name) async {
    if (!_cryptoBox.containsKey(name)) {
      _cryptoBox[name] = await Hive.openBox(
        name,
        encryptionCipher: HiveAesCipher(await key as Uint8List),
      );
    }
    return _cryptoBox[name];
  }

  Future<Box<Server>> getServerBox(String identifier) async {
    return await Hive.openBox<Server>(
      'serverBox-$identifier',
      encryptionCipher: HiveAesCipher(await key as Uint8List),
    );
  }

  Future<Box<CoinWallet>> getWalletBox() async {
    return await Hive.openBox<CoinWallet>(
      'wallets',
      encryptionCipher: HiveAesCipher(await key as Uint8List),
    );
  }
}
