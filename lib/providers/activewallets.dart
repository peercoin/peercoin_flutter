import 'dart:typed_data';

import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/models/walletutxo.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:bip39/bip39.dart' as bip39;

class ActiveWallets with ChangeNotifier {
  EncryptedBox _encryptedBox;
  ActiveWallets(this._encryptedBox);
  String _seedPhrase;
  String _unusedAddress = "";
  Box _walletBox;
  Box _vaultBox;
  Map<String, CoinWallet> _specificWallet = {};

  Future<void> init() async {
    _vaultBox = await _encryptedBox.getGenericBox("vaultBox");
    _walletBox = await _encryptedBox.getWalletBox();
  }

  Future<String> get seedPhrase async {
    if (_seedPhrase == null) {
      _seedPhrase = _vaultBox.get("mnemonicSeed");
    }
    return _seedPhrase;
  }

  String get getUnusedAddress {
    return _unusedAddress;
  }

  set unusedAddress(String newAddr) {
    _unusedAddress = newAddr;
    notifyListeners();
  }

  Uint8List seedPhraseUint8List(String words) {
    return bip39.mnemonicToSeed(words);
  }

  Future<void> createPhrase() async {
    var mnemonicSeed = bip39.generateMnemonic();
    await _vaultBox.put('mnemonicSeed', mnemonicSeed);
    _seedPhrase = mnemonicSeed;
  }

  Future<List> get activeWalletsValues async {
    return _walletBox.values.toList();
  }

  Future<List> get activeWalletsKeys async {
    return _walletBox.keys.toList();
  }

  CoinWallet getSpecificCoinWallet(String identifier) {
    if (_specificWallet[identifier] == null) {
      //cache wallet
      _specificWallet[identifier] = _walletBox.get(identifier);
    }
    return _specificWallet[identifier];
  }

  Future<void> addWallet(String name, String title, String letterCode) async {
    var box = await Hive.openBox<CoinWallet>("wallets",
        encryptionCipher: HiveAesCipher(await _encryptedBox.key));
    await box.put(name, CoinWallet(name, title, letterCode));
    notifyListeners();
  }

  Future<void> generateUnusedAddress(String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);
    NetworkType network =
        AvailableCoins().getSpecificCoin(identifier).networkType;
    var hdWallet = new HDWallet.fromSeed(
      seedPhraseUint8List(await seedPhrase),
      network: network,
    );
    if (openWallet.addresses.isEmpty) {
      //generate new address
      openWallet.addNewAddress = WalletAddress(
          address: hdWallet.address,
          addressBookName: null,
          used: false,
          status: null);
      unusedAddress = hdWallet.address;
    } else {
      //wallet is not brand new, lets find an unused address
      var unusedAddr;
      openWallet.addresses.forEach((walletAddr) {
        if (walletAddr.used == false) {
          unusedAddr = walletAddr.address;
        }
      });
      if (unusedAddr != null) {
        //unused address available
        unusedAddress = unusedAddr;
      } else {
        //not empty, but all used -> create new one
        String newAddress = hdWallet
            .derivePath("m/0'/${openWallet.addresses.length}/0")
            .address;
        openWallet.addNewAddress = WalletAddress(
            address: newAddress,
            addressBookName: null,
            used: false,
            status: null);
        unusedAddress = newAddress;
      }
    }
    await openWallet.save();
  }

  Future<List<WalletAddress>> getWalletAddresses(String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);
    return openWallet.addresses;
  }

  Future<List<WalletTransaction>> getWalletTransactions(
      String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);
    return openWallet.transactions;
  }

  Future<String> getWalletAddressStatus(
      String identifier, String address) async {
    var addresses = await getWalletAddresses(identifier);
    var targetWallet = addresses
        .firstWhere((element) => element.address == address, orElse: null);
    return targetWallet.status;
  }

  Future<List> getUnkownTxFromList(String identifier, List newTxList) async {
    var storedTransactions = await getWalletTransactions(identifier);
    List unkownTx = [];
    newTxList.forEach((newTx) {
      bool found = false;
      storedTransactions.forEach((storedTx) {
        if (storedTx.txid == newTx["tx_hash"]) {
          found = true;
        }
      });
      if (found == false) {
        unkownTx.add(newTx["tx_hash"]);
      }
    });
    return unkownTx;
  }

  Future<void> updateWalletBalance(String identifier) async {
    var openWallet = getSpecificCoinWallet(identifier);

    int balanceConfirmed = 0;
    int unconfirmedBalance = 0;

    openWallet.utxos.forEach((walletUtxo) {
      print("updatebalance ${walletUtxo.hash} ");
      if (walletUtxo.height > 0 ||
          openWallet.transactions.firstWhere(
                (tx) => tx.txid == walletUtxo.hash && tx.direction == "out",
                orElse: () => null,
              ) !=
              null) {
        balanceConfirmed += walletUtxo.value;
      } else {
        unconfirmedBalance += walletUtxo.value;
      }
    });

    openWallet.balance = balanceConfirmed;
    openWallet.unconfirmedBalance = unconfirmedBalance;

    await openWallet.save();
    notifyListeners();
  }

  Future<void> putUtxos(String identifier, String address, List utxos) async {
    var openWallet = getSpecificCoinWallet(identifier);

    //clear utxos for address
    openWallet.clearUtxo(address);

    //put them in again
    utxos.forEach((tx) {
      openWallet.putUtxo(
        WalletUtxo(
            hash: tx["tx_hash"],
            txPos: tx["tx_pos"],
            height: tx["height"],
            value: tx["value"],
            address: address),
      );
    });

    await updateWalletBalance(identifier);
    await openWallet.save();
    notifyListeners();
  }

  Future<void> putTx(String identifier, String address, Map tx) async {
    CoinWallet openWallet = getSpecificCoinWallet(identifier);
    print("$address puttx: $tx");

    //check if that tx is already in the db
    List<WalletTransaction> txInWallet = openWallet.transactions;
    bool isInWallet = false;
    txInWallet.forEach((walletTx) {
      if (walletTx.txid == tx["txid"]) {
        isInWallet = true;
        if (isInWallet == true) {
          if (walletTx.timestamp == null) {
            //did the tx confirm?
            walletTx.newTimestamp = tx["blocktime"];
          }
          if (tx["confirmations"] != null &&
              walletTx.confirmations < tx["confirmations"]) {
            //more confirmations?
            walletTx.newConfirmations = tx["confirmations"];
          }
        }
      }
    });
    //it's not in wallet yet
    if (!isInWallet) {
      //TODO: Play sound! / notification
      var utxoInWallet = openWallet.utxos
          .firstWhere((elem) => elem.hash == tx["txid"], orElse: () => null);
      String direction = utxoInWallet == null ? "out" : "in";
      openWallet.putTransaction(WalletTransaction(
        txid: tx["txid"],
        timestamp: tx["blocktime"],
        value: direction == "in" ? utxoInWallet.value : tx["outValue"],
        fee: direction == "in" ? 0 : tx["outFees"],
        address: address,
        direction: direction,
        broadCasted: direction == "in" ? true : false,
        broadcastHex: direction == "in" ? "" : tx["hex"],
      ));
    }
    notifyListeners();
    await openWallet.save();

    //TODO won't handle TX with multiple outputs to our addresses correctly - utxo will work fine - "only" display issue
  }

  Future<void> updateAddressStatus(
      String identifier, String address, String status) async {
    print("updating $address to $status");
    //set address to used
    //update status for address
    var openWallet = getSpecificCoinWallet(identifier);
    openWallet.addresses.forEach((walletAddr) async {
      if (walletAddr.address == address) {
        walletAddr.newUsed = true;
        walletAddr.newStatus = status;
      }
      await openWallet.save();
    });
    await generateUnusedAddress(identifier);
  }

  Future<String> getAddressForTx(String identifier, String txid) async {
    var openWallet = getSpecificCoinWallet(identifier);
    var tx = openWallet.utxos
        .firstWhere((element) => element.hash == txid, orElse: () => null);
    if (tx != null) {
      return tx.address;
    }
    return "";
  }

  Future<Map> buildTransaction(
    String identifier,
    String address,
    String amount,
    int fee, [
    bool dryRun = false,
  ]) async {
    //convert amount
    int _txAmount = (double.parse(amount) * 1000000).toInt();
    CoinWallet openWallet = getSpecificCoinWallet(identifier);
    String _hex = "";
    int _destroyedChange = 0;

    //check if tx needs change
    bool _needsChange = true;
    if (_txAmount == openWallet.balance) {
      _needsChange = false;
      print("needschange $_needsChange, fee $fee");
      print(_txAmount - fee);
    }
    if (_txAmount <= openWallet.balance) {
      if (openWallet.utxos.length >= 1) {
        //find eligible input utxos
        int _totalInputValue = 0;
        List<WalletUtxo> inputTx = [];
        Coin coin = AvailableCoins().getSpecificCoin(identifier);

        openWallet.utxos.forEach((utxo) {
          if (_totalInputValue <= (_txAmount + fee)) {
            _totalInputValue += utxo.value;
            inputTx.add(utxo);
          }
        });

        NetworkType network =
            AvailableCoins().getSpecificCoin(identifier).networkType;
        var hdWallet = new HDWallet.fromSeed(
          seedPhraseUint8List(await seedPhrase),
          network: network,
        );

        //start building tx
        final tx = TransactionBuilder(network: network);
        tx.setVersion(1);
        if (_needsChange == true) {
          int changeAmount = _totalInputValue - _txAmount - fee;
          print("change amount $changeAmount");
          if (changeAmount < coin.minimumTxValue) {
            //change is too small! no change output
            _destroyedChange = changeAmount;
            tx.addOutput(address, _txAmount - fee);
          } else {
            tx.addOutput(address, _txAmount);
            tx.addOutput(_unusedAddress, changeAmount);
          }
        } else {
          tx.addOutput(address, _txAmount - fee);
        }

        Map<int, Map> keyMap = {};
        inputTx.asMap().forEach((inputKey, inputUtxo) {
          print("inputValue ${inputUtxo.value}");
          //find key to that utxo
          openWallet.addresses.asMap().forEach((key, walletAddr) {
            if (walletAddr.address == inputUtxo.address) {
              int _addrIndex = key;
              var child = hdWallet.address == inputUtxo.address
                  ? hdWallet
                  : hdWallet.derivePath("m/0'/$_addrIndex/0");
              keyMap[inputKey] =
                  ({"wif": child.wif, "addr": inputUtxo.address});
              tx.addInput(inputUtxo.hash, inputUtxo.txPos);
            }
          });
        });

        //sign
        keyMap.forEach((key, value) {
          print("signing - ${value["addr"]} - ${value["wif"]}");
          tx.sign(
            vin: key,
            keyPair: ECPair.fromWIF(value["wif"], network: network),
          );
        });

        final intermediate = tx.build();
        var number = ((intermediate.txSize) / 1000 * coin.feePerKb)
            .toStringAsFixed(coin.fractions);
        var asDouble = double.parse(number) * 1000000;
        int requiredFeeInSatoshis = asDouble.toInt();
        print("fee $requiredFeeInSatoshis, size: ${intermediate.txSize}");
        if (dryRun == false) {
          print(intermediate.txSize);
          _hex = intermediate.toHex();
        }
        //generate new wallet addr
        await generateUnusedAddress(identifier);
        return {
          "fee": dryRun == false
              ? requiredFeeInSatoshis
              : requiredFeeInSatoshis +
                  0, //TODO 10 bytes added here because tx virtualsize out of bitcoin_flutter varies by 1 byte
          "hex": _hex,
          "id": intermediate.getId(),
          "destroyedChange": _destroyedChange
        };
      } else {
        //no utxos available
        //TODO throw custom error
      }
    } else {
      //tx amount greater wallet balance
      //TODO throw custom error
    }
  }

  Future<Map> getWalletScriptHashes(String identifier, [String address]) async {
    var addresses;
    Map answerMap = {};
    if (address == null) {
      //get all
      addresses = await getWalletAddresses(identifier);
      addresses.forEach((addr) {
        answerMap[addr.address] = getScriptHash(identifier, addr.address);
      });
    } else {
      //get just one
      answerMap[address] = getScriptHash(identifier, address);
    }
    return answerMap;
  }

  String getScriptHash(String identifier, String address) {
    NetworkType network =
        AvailableCoins().getSpecificCoin(identifier).networkType;
    var script = Address.addressToOutputScript(address, network);
    var hash = sha256.convert(script).toString();
    return (reverseString(hash));
  }

  void updateBroadcasted(String identifier, String txId, bool broadcasted) {
    CoinWallet openWallet = getSpecificCoinWallet(identifier);
    WalletTransaction tx =
        openWallet.transactions.firstWhere((element) => element.txid == txId);
    tx.broadCasted = broadcasted;
    tx.resetBroadcastHex();
    openWallet.save();
  }

  String reverseString(String input) {
    List items = [];
    for (var i = 0; i < input.length; i++) {
      items.add(input[i]);
    }
    List itemsReversed = [];
    items.asMap().forEach((index, value) {
      if (index % 2 == 0) {
        itemsReversed.insert(0, items[index + 1]);
        itemsReversed.insert(0, value);
      }
    });
    return itemsReversed.join();
  }
}
