import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:peercoin/models/coin_wallet.dart';
import 'package:peercoin/models/wallet_address.dart';
import 'package:peercoin/models/wallet_transaction.dart';
import 'package:peercoin/models/wallet_utxo.dart';
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
  const walletName = 'peercoin';
  final ActiveWallets wallet = ActiveWallets(MockHiveBox());

  setUpAll(() async {
    Hive.init("test");
    Hive.registerAdapter(CoinWalletAdapter());
    Hive.registerAdapter(WalletTransactionAdapter());
    Hive.registerAdapter(WalletAddressAdapter());
    Hive.registerAdapter(WalletUtxoAdapter());
    await wallet.init();
    wallet.addWallet(walletName, walletName, 'ppc');
  });

  tearDownAll(() async {
    File('test/vaultbox.hive').delete();
    File('test/vaultbox.lock').delete();
    File('test/wallets.hive').delete();
    File('test/wallets.lock').delete();
  });

  test(
    'Generate unused address',
    () async {
      await wallet.generateUnusedAddress(walletName);
      assert(wallet.getUnusedAddress == 'PXDR4KZn2WdTocNx1GPJXR96PfzZBvWqKQ');
    },
  );

  test(
    'Add utxo',
    () async {
      await wallet.putUtxos(
        walletName,
        wallet.getUnusedAddress,
        [
          {
            "tx_hash": "asdf",
            "tx_pos": 1,
            "height": 0,
            "value": 10000000,
          }
        ],
      );

      final getUtxos = await wallet.getWalletUtxos(walletName);
      assert(getUtxos.length == 1);
      assert(getUtxos[0].runtimeType == WalletUtxo);
    },
  );
}
