import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:peercoin/models/coin_wallet.dart';
import 'package:peercoin/providers/active_wallets.dart';
import 'package:peercoin/providers/encrypted_box.dart';

class MockHiveBox extends Mock implements EncryptedBox {
  @override
  Future<Uint8List?> get key async {
    return Uint8List(32);
  }

  @override
  Future<Box?> getGenericBox(String name) async {
    return await Hive.openBox(name);
  }

  @override
  Future<Box> getWalletBox() async {
    return await Hive.openBox<CoinWallet>(
      'wallets',
    );
  }
}

void main() async {
  setUpAll(() {
    Hive.init("test");
    Hive.registerAdapter(CoinWalletAdapter());
  });

  tearDownAll(() async {
    File('test/vaultbox.hive').delete();
    File('test/vaultbox.lock').delete();
    File('test/wallets.hive').delete();
    File('test/wallets.lock').delete();
  });

  test(
    'Build transaction',
    () async {
      final ActiveWallets wallet = ActiveWallets(MockHiveBox());
      await wallet.init();
      wallet.addWallet('peercoin', 'peercoin', 'ppc');
      await Future.delayed(const Duration(seconds: 1));
    },
  );
}
