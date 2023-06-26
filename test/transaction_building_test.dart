import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:peercoin/exceptions/exceptions.dart';
import 'package:peercoin/models/coin_wallet.dart';
import 'package:peercoin/models/wallet_address.dart';
import 'package:peercoin/models/wallet_transaction.dart';
import 'package:peercoin/models/wallet_utxo.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/providers/encrypted_box.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;

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
  Future<Box<CoinWallet>> getWalletBox() async {
    return await Hive.openBox<CoinWallet>(
      'wallets',
    );
  }
}

void main() async {
  const walletName = 'peercoin';
  const testnetWalletName = 'peercoinTestnet';
  final WalletProvider wallet = WalletProvider(MockHiveBox());
  TestWidgetsFlutterBinding.ensureInitialized();

  final decimalProduct = pow(
    10,
    6,
  ).toInt();

  setUpAll(() async {
    Hive.init('test');
    Hive.registerAdapter(CoinWalletAdapter());
    Hive.registerAdapter(WalletTransactionAdapter());
    Hive.registerAdapter(WalletAddressAdapter());
    Hive.registerAdapter(WalletUtxoAdapter());
    await wallet.init();
    wallet.addWallet(
      name: walletName,
      title: walletName,
      letterCode: 'PPC',
    );
    wallet.addWallet(
      name: testnetWalletName,
      title: testnetWalletName,
      letterCode: 'tPPC',
    );
  });

  tearDownAll(() async {
    File('test/vaultbox.hive').delete();
    File('test/vaultbox.lock').delete();
    File('test/wallets.hive').delete();
    File('test/wallets.lock').delete();
  });

  group(
    'mainnet',
    () {
      test(
        'Generate unused mainnet address',
        () async {
          await wallet.generateUnusedAddress(walletName, true);
          assert(
            wallet.getUnusedAddress(walletName) ==
                'PXDR4KZn2WdTocNx1GPJXR96PfzZBvWqKQ',
          );
        },
      );

      test(
        'Add mainnet utxo',
        () async {
          await wallet.putUtxos(
            walletName,
            wallet.getUnusedAddress(walletName),
            [
              {
                'tx_hash':
                    '6c0e78d2a2bdc8777e2bb9c30cd25b58a1fb18c7ca55b89a1e179c288da99efd',
                'tx_pos': 1,
                'height': 99,
                'value': 138139, //test output of 0.138139
              }
            ],
          );

          final getUtxos = await wallet.getWalletUtxos(walletName);
          assert(getUtxos.length == 1);
          assert(getUtxos[0].runtimeType == WalletUtxo);
          assert(getUtxos[0].address == wallet.getUnusedAddress(walletName));
        },
      );

      test('Build transaction, spend 100% of wallet balance', () async {
        final result = await wallet.buildTransaction(
          identifier: walletName,
          fee: 0,
          recipients: {
            'p92W3t7YkKfQEPDb7cG9jQ6iMh7cpKLvwK': 138139,
          },
        );
        assert(
          result.hex ==
              '0300000001fd9ea98d289c171e9ab855cac718fba1585bd20cc3b92b7e77c8bda2d2780e6c010000006a47304402207e31cc2a56347884bc52a904819815dc17775795a57c35e648147963c69956a102202a8d6309ea95958e9c28698c2bb23c397e115f358af73e74831e53d3671b4d140121022036646b3fd79dee41351f727f0a6e10d0e7f98585961bc14e7aadaf5f4b66abffffffff01391402000000000017a91426308eea0cfcbe5bc51a5d28f297b92842db43578700000000',
        );
      });

      test('Build transaction, spend ~50% of wallet balance, with change',
          () async {
        final result = await wallet.buildTransaction(
          identifier: walletName,
          fee: 0,
          recipients: {
            'p92W3t7YkKfQEPDb7cG9jQ6iMh7cpKLvwK': 69069,
          },
        );
        assert(
          result.hex ==
              '0300000001fd9ea98d289c171e9ab855cac718fba1585bd20cc3b92b7e77c8bda2d2780e6c010000006a47304402207a4105863579f9226c6a711ec411bc52ad1f3a804efd4faded49ea576d54db670220507762cae442f4572cd63e030bb82d4fb9b27aafcaf717ac33af8062bb28c9090121022036646b3fd79dee41351f727f0a6e10d0e7f98585961bc14e7aadaf5f4b66abffffffff0218050100000000001976a914f82d58dd8487044d8d0879c15a2a3516a425de2a88accd0d01000000000017a91426308eea0cfcbe5bc51a5d28f297b92842db43578700000000',
        );
      });

      test(
          'Build transaction, spend 100% of wallet balance, with fees deducted from last recipient',
          () async {
        final result = await wallet.buildTransaction(
          identifier: walletName,
          fee: 0,
          recipients: {
            'pc1qcanvas0000000000000000000000000000000000000qyscr6u9qpr7jag':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3qr6c9q6sv68g':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3gr659qfnjsyr':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3sr659q5hf3ej':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3cr6c9q85hm6e':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qyjqr6u9qqsdaed':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3qrmq9qj9adud':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3crmq9q0pxvpu':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3srmy9qvjz64g':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3grmy9q3kemge':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3sr6u9qy8ndwd':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3gr6u9qergvnu':
                10000,
            'pc1qcanvas0000000000000000000000000000000000000qy3gr6c9q3t9zv8':
                18000,
          },
        );
        assert(
          result.hex ==
              '0300000001fd9ea98d289c171e9ab855cac718fba1585bd20cc3b92b7e77c8bda2d2780e6c010000006a4730440220402478a7caee83751fda54971f2f6ab1071a4bf17b060f8f4ffd93dcfe08b73e02200ac9fe3e8e01f829c66cfeed48e1a53a970c80aad97ef98c5ff0fd5d279f49b10121022036646b3fd79dee41351f727f0a6e10d0e7f98585961bc14e7aadaf5f4b66abffffffff0d1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024303d70a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024403d60a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d50a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024603d50a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024703d60a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024803d70a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024403d80a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024703d80a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024603d90a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d90a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024603d70a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d70ae32a000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d60a00000000',
        );
      });
    },
  );

  group(
    'testnet',
    () {
      test(
        'Generate unused testnet address',
        () async {
          await wallet.generateUnusedAddress(testnetWalletName, true);
          assert(
            wallet.getUnusedAddress(testnetWalletName) ==
                'n49CCQFuncaXbtBoNm39gSP9dvRP2eFFSw',
          );
        },
      );

      test('Add testnet UTXO', () async {
        await wallet.putUtxos(
          testnetWalletName,
          wallet.getUnusedAddress(testnetWalletName),
          [
            {
              'tx_hash':
                  '6c0e78d2a2bdc8777e2bb9c30cd25b58a1fb18c7ca55b89a1e179c288da99efd',
              'tx_pos': 1,
              'height': 99,
              'value': 10000000, //test output of 10
            }
          ],
        );
        final getUtxos = await wallet.getWalletUtxos(testnetWalletName);
        assert(getUtxos.length == 1);
        assert(getUtxos[0].runtimeType == WalletUtxo);
        assert(
          getUtxos[0].address == wallet.getUnusedAddress(testnetWalletName),
        );
        assert(getUtxos[0].value == 10000000);
      });

      test(
          'Import 1000 addresses from CSV, only have 10 PPC utxo and expect exception',
          () async {
        Map<String, int> recipientMap = {};
        final parsed = fast_csv
            .parse(await File('./test/csvs/test_1000.csv').readAsString());
        for (final row in parsed) {
          final address = row[0];
          final amount = double.parse(
            row[1].replaceAll(',', '.'),
          );
          recipientMap[address] = (amount * decimalProduct).toInt();
        }
        Exception error = Exception();
        try {
          await wallet.buildTransaction(
            identifier: testnetWalletName,
            fee: 0,
            recipients: recipientMap,
          );
        } catch (e) {
          error = e as Exception;
        }
        assert(error.runtimeType == CantPayForFeesException);
        final asCantPayEx = error as CantPayForFeesException;
        assert(asCantPayEx.feesMissing == 421590);
      });

      test('Import 500 addresses from CSV and build', () async {
        Map<String, int> recipientMap = {};
        final parsed = fast_csv
            .parse(await File('./test/csvs/test_500.csv').readAsString());
        for (final row in parsed) {
          final address = row[0];
          final amount = double.parse(
            row[1].replaceAll(',', '.'),
          );
          recipientMap[address] = (amount * decimalProduct).toInt();
        }

        final result = await wallet.buildTransaction(
          identifier: testnetWalletName,
          fee: 0,
          recipients: recipientMap,
        );
        assert(result.totalAmount == 5000000);
        assert(result.fee == 216930);
        assert(
          result.id ==
              '2d5b05caf02eb07571fc3685e404e1c00085ce6bd75862a61ddb282b37d73838',
        );
      });
    },
  );
}
