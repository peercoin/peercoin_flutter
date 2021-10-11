import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/coinwallet.dart';

class BackgroundSync {
  static Future<void> executeSync() async {
    //this static method can't access the providers we already have so we have to re-invent some things here...
    Uint8List _encryptionKey;
    var _secureStorage = const FlutterSecureStorage();

    //check if key exists or return
    if (await _secureStorage.containsKey(key: 'key')) {
      _encryptionKey =
          base64Url.decode((await _secureStorage.read(key: 'key') as String));
    } else {
      return;
    }

    //open wallet box
    var walletBox = await Hive.openBox<CoinWallet>(
      'wallets',
      encryptionCipher: HiveAesCipher(_encryptionKey),
    );

    //loop through wallets
    walletBox.values.forEach((wallet) {
      print(wallet.letterCode);
      //TODO check here if background sync is enabled for lettercode
      wallet.addresses.forEach((address) {
        print(address.address);
      });
    });
  }
}
