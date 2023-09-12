import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:peercoin/exceptions/exceptions.dart';
import 'package:peercoin/models/hive/coin_wallet.dart';
import 'package:peercoin/models/hive/wallet_address.dart';
import 'package:peercoin/models/hive/wallet_transaction.dart';
import 'package:peercoin/models/hive/wallet_utxo.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/providers/encrypted_box_provider.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;

class MockHiveBox extends Mock implements EncryptedBoxProvider {
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

  //init coinlib
  await loadCoinlib();

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
      isImportedSeed: false,
    );
    wallet.addWallet(
      name: testnetWalletName,
      title: testnetWalletName,
      letterCode: 'tPPC',
      isImportedSeed: false,
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
          await wallet.generateUnusedAddress(walletName);
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
        assert(result.feesHaveBeenDeductedFromRecipient == true);
        assert(
          result.hex ==
              '0300000001fd9ea98d289c171e9ab855cac718fba1585bd20cc3b92b7e77c8bda2d2780e6c010000006a4730440220166f0bcbfac940bf280ab88a804574bbc49f6629ecbe1852a7a4aa7ad3da9a31022012dd79b7ea62b79bf581253522476a6ee7fb944a6334fb34462f8d3b363013140121022036646b3fd79dee41351f727f0a6e10d0e7f98585961bc14e7aadaf5f4b66abffffffff01391402000000000017a91426308eea0cfcbe5bc51a5d28f297b92842db43578700000000',
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
              '0300000001fd9ea98d289c171e9ab855cac718fba1585bd20cc3b92b7e77c8bda2d2780e6c010000006a473044022057df35cb499de4719fbf5d46291daf89aef0f9f2dde20597305cba276cbb54ad02205cec9803aa8df586312d9bf704278ff4b01b8fc3e284b10097137be554d809aa0121022036646b3fd79dee41351f727f0a6e10d0e7f98585961bc14e7aadaf5f4b66abffffffff0218050100000000001976a914f82d58dd8487044d8d0879c15a2a3516a425de2a88accd0d01000000000017a91426308eea0cfcbe5bc51a5d28f297b92842db43578700000000',
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
        assert(result.feesHaveBeenDeductedFromRecipient == true);
        assert(
          result.hex ==
              '0300000001fd9ea98d289c171e9ab855cac718fba1585bd20cc3b92b7e77c8bda2d2780e6c010000006a473044022040ef9009ab2843bc66c7ae09b23b7b23a0f7d62cf990da0f2b45257ecc810a1e02200862f8b6a880bb65a0f140e0eaadda11e090d826abe0fc80454461bfbc4cb0010121022036646b3fd79dee41351f727f0a6e10d0e7f98585961bc14e7aadaf5f4b66abffffffff0d1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024303d70a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024403d60a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d50a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024603d50a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024703d60a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024803d70a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024403d80a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024703d80a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024603d90a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d90a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024603d70a1027000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d70ae32a000000000000220020c766cec1ef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde024503d60a00000000',
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
          await wallet.generateUnusedAddress(testnetWalletName);
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

      test('Send OP_RETURN message from 0 Output', () async {
        final result = await wallet.buildTransaction(
          identifier: testnetWalletName,
          fee: 0,
          recipients: {
            'n4pJDAqsagWbouT7G7xRH8548s9pZpQwtG': 0,
          },
          opReturn: 'test',
        );

        assert(result.fee == 2400);
        assert(
          result.hex ==
              '0300000001fd9ea98d289c171e9ab855cac718fba1585bd20cc3b92b7e77c8bda2d2780e6c010000006a47304402207b90e7910dcf86a6b6dc3f7a99109cdbe9b8a11a894a56633c5ea384abe44a6f02206052da8d5d2de4ff7a17ef18e3efadefbe7b3125ccb2440e4d509e192689a17b0121022036646b3fd79dee41351f727f0a6e10d0e7f98585961bc14e7aadaf5f4b66abffffffff03208d9800000000001976a914f82d58dd8487044d8d0879c15a2a3516a425de2a88ac00000000000000001976a914ff9296d92c5efc397d0e0b9ebe94d95a532270c488ac0000000000000000066a047465737400000000',
        );
      });

      test('Find OP_RETURN message in Tx', () async {
        const tx = '''
        {
          "txid": "93b625d6d3c34d84a5f81c9aea1f509090d64c39b5b12da926e55122416f6cdd",
          "hash": "93b625d6d3c34d84a5f81c9aea1f509090d64c39b5b12da926e55122416f6cdd",
          "version": 3,
          "time": 0,
          "size": 238,
          "vsize": 238,
          "weight": 952,
          "locktime": 0,
          "vin": [
            {
              "txid": "c67d874de945d10ab7da1d85de0681e53359559d14e80b2114d8ffbf68839c49",
              "vout": 0,
              "scriptSig": {
                "asm": "3044022032ae74d15ba45916b8183748e20317d1d84347fd27d458c7c0f296f1837347d802205e5df2aa058fb6b88452b80843f05c5cbb9848c98e73919218fca5fa831daa21[ALL] 025bfb039e390283e1682c53aa19087725b63039f9f18d32a3ff3be444669b31df",
                "hex": "473044022032ae74d15ba45916b8183748e20317d1d84347fd27d458c7c0f296f1837347d802205e5df2aa058fb6b88452b80843f05c5cbb9848c98e73919218fca5fa831daa210121025bfb039e390283e1682c53aa19087725b63039f9f18d32a3ff3be444669b31df"
              },
              "sequence": 4294967295
            }
          ],
          "vout": [
            {
              "value": 9.500994,
              "n": 0,
              "scriptPubKey": {
                "asm": "OP_DUP OP_HASH160 e6cf69bef993f88d547cd0a6fca17a4a4ed3e0c5 OP_EQUALVERIFY OP_CHECKSIG",
                "desc": "addr(n2ZNBVFB9Rob6CBxUz4L7JhkkRsohddptN)#vwhka9fn",
                "hex": "76a914e6cf69bef993f88d547cd0a6fca17a4a4ed3e0c588ac",
                "address": "n2ZNBVFB9Rob6CBxUz4L7JhkkRsohddptN",
                "type": "pubkeyhash"
              }
            },
            {
              "value": 0,
              "n": 1,
              "scriptPubKey": {
                "asm": "OP_DUP OP_HASH160 e611a8894f845a0a99e8f87d16850ef1bbfea819 OP_EQUALVERIFY OP_CHECKSIG",
                "desc": "addr(n2VSs6f787ebhgRRnURdLtinCkPjDT4zZ7)#2l0s7aqf",
                "hex": "76a914e611a8894f845a0a99e8f87d16850ef1bbfea81988ac",
                "address": "n2VSs6f787ebhgRRnURdLtinCkPjDT4zZ7",
                "type": "pubkeyhash"
              }
            },
            {
              "value": 0,
              "n": 2,
              "scriptPubKey": {
                "asm": "OP_RETURN 26952",
                "desc": "raw(6a024869)#nz6xdglz",
                "hex": "6a024869",
                "type": "nulldata"
              }
            }
          ],
          "hex": "0300000001499c8368bfffd814210be8149d555933e58106de851ddab70ad145e94d877dc6000000006a473044022032ae74d15ba45916b8183748e20317d1d84347fd27d458c7c0f296f1837347d802205e5df2aa058fb6b88452b80843f05c5cbb9848c98e73919218fca5fa831daa210121025bfb039e390283e1682c53aa19087725b63039f9f18d32a3ff3be444669b31dfffffffff0342f99000000000001976a914e6cf69bef993f88d547cd0a6fca17a4a4ed3e0c588ac00000000000000001976a914e611a8894f845a0a99e8f87d16850ef1bbfea81988ac0000000000000000046a02486900000000",
          "blockhash": "d8f5dc9f9d403ab5313319d7c6c5c96db48cf44c5f1aa04927b74d8280184dbe",
          "confirmations": 3,
          "blocktime": 1694515176
        }
        ''';

        const address = 'n2VSs6f787ebhgRRnURdLtinCkPjDT4zZ7';

        await wallet.addAddressFromWif(
          testnetWalletName,
          '',
          address,
        );

        await wallet.putUtxos(
          testnetWalletName,
          address,
          json.decode(
            '[{"tx_hash": "93b625d6d3c34d84a5f81c9aea1f509090d64c39b5b12da926e55122416f6cdd", "tx_pos": 1, "height": 546555, "value": 0}]',
          ),
        );

        await wallet.putTx(
          identifier: testnetWalletName,
          address: address,
          tx: json.decode(tx),
          notify: false,
        );

        final txn = await wallet.getWalletTransactions(testnetWalletName);

        assert(txn[1].opReturn == 'Hi');
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
              '4fe5d84ee747a358fffa808fef6166b04b58eaafddeaaa3b2ee68437cbc13807',
        );
      });
    },
  );
}
