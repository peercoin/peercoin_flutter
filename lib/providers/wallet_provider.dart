// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:peercoin/models/buildresult.dart';

import '../exceptions/exceptions.dart';
import '../models/available_coins.dart';
import '../models/hive/coin_wallet.dart';
import '../models/hive/wallet_address.dart';
import '../models/hive/wallet_transaction.dart';
import '../models/hive/wallet_utxo.dart';
import '../tools/app_localizations.dart';
import '../tools/logger_wrapper.dart';
import '../tools/notification.dart';
import 'encrypted_box_provider.dart';

class WalletProvider with ChangeNotifier {
  final EncryptedBoxProvider _encryptedBox;

  final Map<String, CoinWallet> _coinWalletCache = {};
  final Map<String, HDPrivateKey> _hdWalletCache = {};
  final Map<String, String> _unusedAddressCache = {};
  final Map<String, String> _wifs = {};
  final _opReturn = ScriptOpCode.fromName('RETURN');
  late String _seedPhrase;
  late Box<CoinWallet> _walletBox;
  late Box _vaultBox;
  WalletProvider(this._encryptedBox);

  List get availableWalletKeys {
    return _walletBox.keys.toList();
  }

  List<CoinWallet> get availableWalletValues {
    return _walletBox.values.toList();
  }

  Future<String> get seedPhrase async {
    _seedPhrase = _vaultBox.get('mnemonicSeed') ?? '';
    return _seedPhrase;
  }

  Future<void> addAddressFromScan({
    required String identifier,
    required String address,
    required String status,
  }) async {
    final openWallet = getSpecificCoinWallet(identifier);
    final addr = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    if (addr == null) {
      openWallet.addNewAddress = WalletAddress(
        address: address,
        addressBookName: '',
        used: true,
        status: status,
        isOurs: true,
        wif: await getWif(
          identifier: identifier,
          address: address,
        ),
        isWatchOnly: false,
      );
    } else {
      await updateAddressStatus(identifier, address, status);
    }

    await openWallet.save();
  }

  Future<void> addAddressFromWif({
    required String identifier,
    required String wif,
    required String address,
  }) async {
    final openWallet = getSpecificCoinWallet(identifier);

    openWallet.addNewAddress = WalletAddress(
      address: address,
      addressBookName: '',
      used: true,
      status: null,
      isOurs: true,
      wif: wif,
      isWatchOnly: false,
    );

    await openWallet.save();
  }

  Future<void> addWallet({
    required String name,
    required String title,
    required String letterCode,
    required bool isImportedSeed,
    required bool watchOnly,
    required bool isROAST,
  }) async {
    final box = await _encryptedBox.getWalletBox();
    final nOfWalletOfLetterCode = availableWalletValues
        .where(
          (element) =>
              element.letterCode == letterCode && element.watchOnly == false,
        )
        .length;

    LoggerWrapper.logInfo(
      'WalletProvider',
      'addWallet',
      'writing $name - $title - $letterCode - $nOfWalletOfLetterCode ',
    );

    await box.put(
      name,
      CoinWallet(
        name,
        title,
        letterCode,
        nOfWalletOfLetterCode,
        isImportedSeed,
        watchOnly,
        isROAST,
      ),
    );

    notifyListeners();
  }

  Future<BuildResult> buildTransaction({
    required String identifier,
    required int fee,
    required Map<String, int> recipients,
    String opReturn = '',
    bool firstPass = true,
    int sizeBefore = 0,
    List<WalletUtxo>? paperWalletUtxos,
    String paperWalletPrivkey = '',
  }) async {
    //convert amount
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: identifier,
    );

    int txAmount = 0;
    txAmount = parseTxOutputValue(recipients);

    final openWallet = getSpecificCoinWallet(identifier);
    String hex = '';
    int destroyedChange = 0;

    LoggerWrapper.logInfo(
      'WalletProvider',
      'buildTransaction',
      'started - firstPass: $firstPass',
    );

    //check if tx needs change
    bool needsChange = true;
    LoggerWrapper.logInfo(
      'WalletProvider',
      'buildTransaction',
      'txAmount: $txAmount - wallet balance: ${openWallet.balance}',
    );

    if (txAmount == openWallet.balance || paperWalletUtxos != null) {
      needsChange = false;
    }

    LoggerWrapper.logInfo(
      'WalletProvider',
      'buildTransaction',
      'needschange $needsChange, fee $fee',
    );

    //define utxo pool
    final utxoPool = paperWalletUtxos ?? openWallet.utxos;

    // CoinSelection.optimal(
    //   candidates: [InputCandidate(input: Input(), value: BigInt())],
    //   recipients: recipients,
    //   changeProgram: changeProgram,
    //   feePerKb: fee,
    //   minFee: minFee,
    //   minChange: minChange,
    // ); TODO

    if (txAmount <= openWallet.balance || paperWalletUtxos != null) {
      if (utxoPool.isNotEmpty) {
        //find eligible input utxos
        int totalInputValue = 0;
        final inputUtxos = <WalletUtxo>[];
        final coin = AvailableCoins.getSpecificCoin(identifier);

        for (final utxo in utxoPool) {
          if (utxo.value > 0) {
            if (utxo.height > 0 ||
                openWallet.transactions.firstWhereOrNull(
                      (tx) => tx.txid == utxo.hash && tx.direction == 'out',
                    ) !=
                    null ||
                paperWalletUtxos != null) {
              if ((needsChange && totalInputValue <= (txAmount + fee)) ||
                  (needsChange == false &&
                      totalInputValue < (txAmount + fee))) {
                totalInputValue += utxo.value;
                inputUtxos.add(utxo);
                LoggerWrapper.logInfo(
                  'WalletProvider',
                  'buildTransaction',
                  'adding inputTx: ${utxo.hash} (${utxo.value}) - totalInputValue: $totalInputValue',
                );
              }
            } else {
              LoggerWrapper.logInfo(
                'WalletProvider',
                'buildTransaction',
                'discarded inputTx: ${utxo.hash} (${utxo.value}) because unconfirmed',
              );
            }
          }
        }

        final coinParams = AvailableCoins.getSpecificCoin(identifier);
        final network = coinParams.networkType;

        //start building tx
        List<Input> txInputs = [];
        List<Output> txOutputs = [];

        final changeAmount = needsChange ? totalInputValue - txAmount - fee : 0;
        bool feesHaveBeenDeductedFromRecipient = false;

        if (needsChange == true) {
          LoggerWrapper.logInfo(
            'WalletProvider',
            'buildTransaction',
            'change amount $changeAmount, tx amount $txAmount, fee $fee',
          );

          if (changeAmount < coin.minimumTxValue) {
            //change is too small! no change output, add dust to last output
            destroyedChange = totalInputValue - txAmount;
            if (txAmount > 0) {
              LoggerWrapper.logInfo(
                'WalletProvider',
                'buildTransaction',
                'dust of $destroyedChange added to ${recipients.keys.last}',
              );
              recipients.update(recipients.keys.last, (value) {
                if (value + destroyedChange < totalInputValue) {
                  feesHaveBeenDeductedFromRecipient = true;
                  return value + destroyedChange;
                }
                return value;
              });
            }
          } else {
            //add change output to unused address
            LoggerWrapper.logInfo(
              'WalletProvider',
              'buildTransaction',
              'change output added for ${recipients.keys.last} $changeAmount',
            );
            txOutputs.add(
              Output.fromAddress(
                BigInt.from(changeAmount),
                Address.fromString(getUnusedAddress(identifier), network),
              ),
            );
          }
        } else if (txAmount + fee > totalInputValue) {
          //empty wallet case - full wallet balance has been requested but fees have to be paid
          LoggerWrapper.logInfo(
            'WalletProvider',
            'buildTransaction',
            'no change needed, tx amount $txAmount, fee $fee, reduced output added for ${recipients.keys.last} ${txAmount - fee}',
          );
          recipients.update(recipients.keys.last, (value) => value - fee);
          if (recipients.values.last < coin.minimumTxValue) {
            throw CantPayForFeesException(
              recipients.values.last * -1,
            );
          }
          txAmount = parseTxOutputValue(recipients);
          feesHaveBeenDeductedFromRecipient = true;
        }

        //add recipient outputs
        recipients.forEach((address, amount) {
          LoggerWrapper.logInfo(
            'WalletProvider',
            'buildTransaction',
            'adding output $amount for recipient $address',
          );
          txOutputs.add(
            Output.fromAddress(
              BigInt.from(amount),
              Address.fromString(address, network),
            ),
          );
        });

        //safety check of totalInputValue
        if (totalInputValue >
                (txAmount + destroyedChange + fee + changeAmount) &&
            paperWalletUtxos == null) {
          throw ('totalInputValue safety mechanism triggered');
        }

        //correct txAmount for fees if txAmount is 0
        bool allRecipientOutPutsAreZero = false;
        if (txAmount == 0) {
          txAmount += fee;
          allRecipientOutPutsAreZero = true;
        }

        //add OP_RETURN if exists
        if (opReturn.isNotEmpty) {
          LoggerWrapper.logInfo(
            'WalletProvider',
            'buildTransaction',
            'adding opReturn $opReturn',
          );

          final script = Script([
            _opReturn,
            ScriptPushData(utf8.encode(opReturn)),
          ]);

          txOutputs.add(
            Output.fromProgram(
              BigInt.zero,
              RawProgram(script),
            ),
          );
        }

        //generate keyMap
        final keyMap = <int, Map>{};
        for (final inputUtxo in inputUtxos) {
          final inputN = inputUtxos.indexOf(inputUtxo);
          //find key to that utxo
          for (final walletAddr in openWallet.addresses) {
            if (walletAddr.address == inputUtxo.address) {
              final wif = paperWalletUtxos != null
                  ? paperWalletPrivkey
                  : await getWif(
                      identifier: identifier,
                      address: walletAddr.address,
                    );
              keyMap[inputN] = {'wif': wif, 'addr': inputUtxo.address};

              txInputs.add(
                P2PKHInput(
                  prevOut: OutPoint.fromHex(
                    inputUtxo.hash,
                    inputUtxo.txPos,
                  ),
                  publicKey: WIF.fromString(wif).privkey.pubkey,
                ),
              );
            }
          }
        }

        Transaction tx = Transaction(
          inputs: txInputs,
          outputs: txOutputs,
          version: coinParams.txVersion,
        );

        //sign
        keyMap.forEach(
          (i, value) {
            LoggerWrapper.logInfo(
              'WalletProvider',
              'buildTransaction',
              "signing - ${value["addr"]} at vin $i",
            );

            tx = tx.sign(
              inputN: i,
              key: WIF.fromString(value['wif']).privkey,
            );
          },
        );

        final number = (tx.size / 1000 * coin.fixedFeePerKb)
            .toStringAsFixed(coin.fractions);
        final asDouble = double.parse(number) * decimalProduct;
        final requiredFeeInSatoshis = asDouble.round();

        LoggerWrapper.logInfo(
          'WalletProvider',
          'buildTransaction',
          'fee $requiredFeeInSatoshis, size: ${tx.size}',
        );

        LoggerWrapper.logInfo(
          'WalletProvider',
          'buildTransaction',
          'sizeBefore: $sizeBefore - size now: ${tx.size}',
        );

        if (firstPass == true || tx.size > sizeBefore) {
          // dump hexes
          return await buildTransaction(
            identifier: identifier,
            recipients: recipients,
            opReturn: opReturn,
            fee: requiredFeeInSatoshis,
            sizeBefore: tx.size,
            firstPass: false,
            paperWalletPrivkey: paperWalletPrivkey,
            paperWalletUtxos: paperWalletUtxos,
          );
        } else {
          //second pass or later
          LoggerWrapper.logInfo(
            'WalletProvider',
            'buildTransaction',
            'intermediate size: ${tx.size}',
          );
          hex = tx.toHex();
          return BuildResult(
            fee: requiredFeeInSatoshis,
            hex: hex,
            recipients: recipients,
            totalAmount: txAmount,
            id: tx.txid,
            destroyedChange: destroyedChange,
            opReturn: opReturn,
            neededChange: needsChange,
            allRecipientOutPutsAreZero: allRecipientOutPutsAreZero,
            feesHaveBeenDeductedFromRecipient:
                feesHaveBeenDeductedFromRecipient,
            inputTx: inputUtxos,
          );
        }
      } else {
        throw ('no utxos available');
      }
    } else {
      throw ('tx amount greater wallet balance');
    }
  }

  void closeWallet(String identifier) {
    _coinWalletCache.removeWhere((key, _) => key == identifier);
    _hdWalletCache.removeWhere((key, _) => key == identifier);
    _wifs.removeWhere((key, _) => key == identifier);
    _unusedAddressCache.removeWhere((key, _) => key == identifier);
  }

  Future<void> createPhrase([
    String? providedPhrase,
    int strength = 128,
  ]) async {
    if (providedPhrase == null) {
      final mnemonicSeed = bip39.generateMnemonic(strength: strength);
      await _vaultBox.put('mnemonicSeed', mnemonicSeed);
      _seedPhrase = mnemonicSeed;
    } else {
      await _vaultBox.put('mnemonicSeed', providedPhrase);
      _seedPhrase = providedPhrase;
    }
  }

  void createWatchOnlyAddres({
    required String identifier,
    required String address,
    required String label,
  }) {
    final openWallet = getSpecificCoinWallet(identifier);

    openWallet.addNewAddress = WalletAddress(
      address: address,
      addressBookName: label,
      used: false,
      status: null,
      isOurs: true,
      wif: '',
      isWatchOnly: true,
    );

    openWallet.save();
    notifyListeners();
  }

  Future<void> deleteWatchOnlyWallet(String identifier) async {
    final openWallet = getSpecificCoinWallet(identifier);
    if (openWallet.watchOnly == false) {
      throw Exception('Wallet is not watch only');
    }

    await _walletBox.delete(identifier);

    closeWallet(identifier);
    notifyListeners();
  }

  Future<void> deleteROASTWallet(String identifier) async {
    final openWallet = getSpecificCoinWallet(identifier);
    if (openWallet.isROAST == false) {
      throw Exception('Wallet is not ROAST');
    }

    await _walletBox.delete(identifier);
    await _vaultBox.delete(identifier);

    closeWallet(identifier);
    notifyListeners();
  }

  Future<void> generateUnusedAddress(String identifier) async {
    final openWallet = getSpecificCoinWallet(identifier);
    final hdWallet = await getHdWallet(identifier);

    if (openWallet.watchOnly == true) {
      return;
    }

    if (openWallet.addresses.isEmpty && openWallet.walletIndex == 0) {
      //generate new address from master at wallet index 0
      openWallet.addNewAddress = WalletAddress(
        address: getAddressFromHDPrivateKey(identifier, hdWallet),
        addressBookName: '',
        used: false,
        status: null,
        isOurs: true,
        wif: getWifFromHDPrivateKey(identifier, hdWallet),
        isWatchOnly: false,
      );
      setUnusedAddress(
        identifier: identifier,
        address: getAddressFromHDPrivateKey(identifier, hdWallet),
      );
    } else {
      //lets find an unused address
      String? unusedAddr;
      for (final walletAddr in openWallet.addresses) {
        if (walletAddr.used == false && walletAddr.status == null) {
          unusedAddr = walletAddr.address;
        }
      }
      if (unusedAddr != null) {
        //unused address available
        setUnusedAddress(identifier: identifier, address: unusedAddr);
      } else {
        //not empty, but all used -> create new one
        int numberOfOurAddr = openWallet.addresses
            .where((element) => element.isOurs == true)
            .length;
        String derivePath = "m/${openWallet.walletIndex}'/$numberOfOurAddr/0";
        HDPrivateKey newHdWallet = hdWallet.derivePath(derivePath);
        final newHdWalletAddress = getAddressFromHDPrivateKey(
          identifier,
          newHdWallet,
        );
        WalletAddress? newAddrResult = openWallet.addresses.firstWhereOrNull(
          (element) => element.address == newHdWalletAddress,
        );

        while (newAddrResult != null) {
          //next addr in derivePath already exists for some reason, find a non-existing one
          numberOfOurAddr++;
          derivePath = "m/${openWallet.walletIndex}'/$numberOfOurAddr/0";
          newHdWallet = hdWallet.derivePath(derivePath);

          newAddrResult = openWallet.addresses.firstWhereOrNull(
            (element) => element.address == newHdWalletAddress,
          );
        }

        openWallet.addNewAddress = WalletAddress(
          address: newHdWalletAddress,
          addressBookName: '',
          used: false,
          status: null,
          isOurs: true,
          wif: getWifFromHDPrivateKey(identifier, newHdWallet),
          isWatchOnly: false,
        );

        setUnusedAddress(
          identifier: identifier,
          address: newHdWalletAddress,
        );
      }
    }
    await openWallet.save();
  }

  Future<String> getAddressForTx(String identifier, String txid) async {
    final openWallet = getSpecificCoinWallet(identifier);
    final tx =
        openWallet.utxos.firstWhereOrNull((element) => element.hash == txid);
    if (tx != null) {
      return tx.address;
    }
    return '';
  }

  Future<String> getAddressFromDerivationPath({
    required String identifier,
    required int account,
    required int chain,
    required int address,
    bool isMaster = false,
  }) async {
    final hdWallet = await getHdWallet(identifier);

    if (isMaster == true) {
      return getAddressFromHDPrivateKey(
        identifier,
        hdWallet,
      );
    } else {
      final derivePath = "m/$account'/$chain/$address";
      LoggerWrapper.logInfo(
        'WalletProvider',
        'getAddressFromDerivationPath',
        derivePath,
      );

      return getAddressFromHDPrivateKey(
        identifier,
        hdWallet.derivePath(derivePath),
      );
    }
  }

  String getAddressFromHDPrivateKey(
    String identifier,
    HDPrivateKey hdPrivateKey,
  ) =>
      P2PKHAddress.fromPublicKey(
        hdPrivateKey.publicKey,
        version:
            AvailableCoins.getSpecificCoin(identifier).networkType.p2pkhPrefix,
      ).toString();

  Future<Map> getAllWalletScriptHashes(String identifier) async {
    List<WalletAddress>? addresses;
    final answerMap = {};
    //get all
    addresses = await getWalletAddresses(identifier);
    for (final addr in addresses) {
      if (addr.isOurs == true) {
        if (addr.status == null) {
          answerMap[addr.address] = getScriptHash(identifier, addr.address);
        }
      }
    }
    return answerMap;
  }

  Future<HDPrivateKey> getHdWallet(String identifier) async {
    if (_hdWalletCache.containsKey(identifier)) {
      return _hdWalletCache[identifier]!;
    } else {
      _hdWalletCache[identifier] = HDPrivateKey.fromSeed(
        seedPhraseUint8List(await seedPhrase),
      );
      return _hdWalletCache[identifier]!;
    }
  }

  String getLabelForAddress(String identifier, String address) {
    final openWallet = getSpecificCoinWallet(identifier);
    final addr = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    if (addr == null) return '';
    return addr.addressBookName;
  }

  String getScriptHash(String identifier, String address) {
    LoggerWrapper.logInfo(
      'WalletProvider',
      'getScriptHash',
      'getting script hash for $address in $identifier',
    );

    final network = AvailableCoins.getSpecificCoin(identifier).networkType;
    final script = Address.fromString(address, network).program.script.compiled;
    final hash = sha256.convert(script).toString();
    return (reverseString(hash));
  }

  CoinWallet getSpecificCoinWallet(String identifier) {
    if (_coinWalletCache[identifier] == null) {
      //cache wallet
      final res = _walletBox.get(identifier);
      if (res == null) {
        throw Exception('Wallet not found');
      } else {
        _coinWalletCache[identifier] = res;
      }
    }
    return _coinWalletCache[identifier]!;
  }

  String getUnusedAddress(String identifier) {
    return _unusedAddressCache[identifier] ?? '';
  }

  Future<List<WalletAddress>> getWalletAddresses(String identifier) async {
    final openWallet = getSpecificCoinWallet(identifier);
    return openWallet.addresses;
  }

  Future<String?> getWalletAddressStatus(
    String identifier,
    String address,
  ) async {
    final addresses = await getWalletAddresses(identifier);
    final targetWallet = addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    return targetWallet?.status;
  }

  int getWalletNumber(String identifier) {
    final openWallet = getSpecificCoinWallet(identifier);
    return openWallet.walletIndex;
  }

  Future<List<WalletTransaction>> getWalletTransactions(
    String identifier,
  ) async {
    final openWallet = getSpecificCoinWallet(identifier);
    return openWallet.transactions;
  }

  Future<List<WalletUtxo>> getWalletUtxos(String identifier) async {
    final openWallet = getSpecificCoinWallet(identifier);
    return openWallet.utxos;
  }

  Future<Map> getWatchedWalletScriptHashes(
    String identifier, [
    String? address,
  ]) async {
    List<WalletAddress>? addresses;
    final answerMap = {};
    if (address == null) {
      //get all
      final utxos = await getWalletUtxos(identifier);
      addresses = await getWalletAddresses(identifier);
      for (final addr in addresses) {
        if (addr.isOurs == true) {
          //does addr have a balance?
          final utxoRes = utxos.firstWhereOrNull(
            (element) => element.address == addr.address,
          );

          bool isWatchedCheck = addr.isWatched ||
              addr.isWatchOnly ||
              utxoRes != null && utxoRes.value > 0 ||
              addr.address == getUnusedAddress(identifier) ||
              addr.status == 'hasUtxo';

          if (isWatchedCheck == true) {
            answerMap[addr.address] = getScriptHash(identifier, addr.address);
          }
        }
      }
    } else {
      //get just one
      answerMap[address] = getScriptHash(identifier, address);
    }
    return answerMap;
  }

  Future<String> getWif({
    required String identifier,
    required String address,
  }) async {
    final openWallet = getSpecificCoinWallet(identifier);
    final walletAddress = openWallet.addresses
        .firstWhereOrNull((element) => element.address == address);

    if (walletAddress != null) {
      if (walletAddress.wif == '') {
        //no wif set
        await populateWifMap(
          identifier: identifier,
          maxValue: openWallet.addresses.length,
          walletNumber: openWallet.walletIndex,
        );
        walletAddress.newWif = _wifs[address] ?? ''; //save
        await openWallet.save();

        return _wifs[walletAddress.address] ?? '';
      }
    } else if (walletAddress == null) {
      return '';
    }
    return walletAddress.wif;
  }

  String getWifFromHDPrivateKey(String identifier, HDPrivateKey hdWallet) =>
      WIF(
        privkey: hdWallet.privateKey,
        version:
            AvailableCoins.getSpecificCoin(identifier).networkType.wifPrefix,
      ).toString();

  Future<void> init() async {
    //set vaultBox
    final vaultBoxRes = await _encryptedBox.getGenericBox('vaultBox');
    if (vaultBoxRes != null) {
      _vaultBox = vaultBoxRes;
    } else {
      throw Exception('Vault box not found');
    }

    //set walletBox
    _walletBox = await _encryptedBox.getWalletBox();
  }

  int parseTxOutputValue(Map<String, int> recipients) {
    int txAmount = 0;
    recipients.forEach(
      (_, amount) {
        txAmount += amount;
      },
    );
    return txAmount;
  }

  Future<void> populateWifMap({
    required String identifier,
    required int maxValue,
    required int walletNumber,
  }) async {
    final hdWallet = await getHdWallet(identifier);

    for (int i = 0; i <= maxValue + 1; i++) {
      final child = hdWallet.derivePath("m/$walletNumber'/$i/0");
      _wifs[getAddressFromHDPrivateKey(identifier, child)] =
          getWifFromHDPrivateKey(identifier, child);
    }
    _wifs[getAddressFromHDPrivateKey(identifier, hdWallet)] =
        getWifFromHDPrivateKey(identifier, hdWallet);
  }

  Future<void> prepareForRescan(String identifier) async {
    final openWallet = getSpecificCoinWallet(identifier);
    openWallet.utxos.removeRange(0, openWallet.utxos.length);
    openWallet.transactions.removeWhere(
      (element) => element.broadCasted == false,
    );

    for (final element in openWallet.addresses) {
      element.newStatus = null;
      element.newNotificationBackendCount = 0;
    }

    await updateWalletBalance(identifier);
    await updateDueForRescan(identifier: identifier, newState: true);
    await openWallet.save();
  }

  Future<void> putOutgoingTx({
    required String identifier,
    required BuildResult buildResult,
    required int totalValue,
    required int totalFees,
  }) async {
    final openWallet = getSpecificCoinWallet(identifier);

    openWallet.putTransaction(
      WalletTransaction(
        txid: buildResult.id,
        timestamp: 0,
        value: totalValue,
        fee: totalFees,
        recipients: buildResult.recipients,
        address: buildResult.recipients.keys.first,
        direction: 'out',
        broadCasted: false,
        confirmations: 0,
        broadcastHex: buildResult.hex,
        opReturn: buildResult.opReturn,
      ),
    );

    //check recipients if one of them is our address but not the current change address (sending coins to oneself)
    final changeAddress = getUnusedAddress(identifier);

    for (final recipientAddr in buildResult.recipients.keys) {
      if (recipientAddr != changeAddress) {
        if (openWallet.addresses.firstWhereOrNull(
              (element) => element.address == recipientAddr,
            ) !=
            null) {
          //found recipient in the transaction that is not the changeAddress but our address
          final value = buildResult.recipients[recipientAddr] ?? 0;

          LoggerWrapper.logInfo(
            'WalletProvider',
            'putOutgoingTx',
            'isSendingToSelf: $recipientAddr $value',
          );

          //write tx
          openWallet.putTransaction(
            WalletTransaction(
              txid: buildResult.id,
              timestamp: 0,
              value: value,
              fee: 0,
              recipients: {recipientAddr: value},
              address: recipientAddr,
              direction: 'in',
              broadCasted: false,
              confirmations: 0,
              broadcastHex: '',
              opReturn: buildResult.opReturn,
            ),
          );
        }
      }
    }

    //flag _unusedAddress as change addr
    final addrInWallet = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == changeAddress,
    );
    if (addrInWallet != null) {
      if (buildResult.neededChange == true) {
        addrInWallet.isChangeAddr = true;
      }
      //increase notification value
      addrInWallet.newNotificationBackendCount =
          addrInWallet.notificationBackendCount + 1;
    }

    //generate new wallet addr
    await generateUnusedAddress(identifier);

    notifyListeners();
    await openWallet.save();
  }

  Future<void> putTx({
    required String identifier,
    required String address,
    required Map tx,
    bool notify = true,
  }) async {
    final openWallet = getSpecificCoinWallet(identifier);
    LoggerWrapper.logInfo('WalletProvider', 'putTx', '$address puttx: $tx');

    //check if that tx is already in the db
    final txInWallet = openWallet.transactions;
    bool isInWallet = false;
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: identifier,
    );

    for (final walletTx in txInWallet) {
      if (walletTx.txid == tx['txid']) {
        isInWallet = true;
        if (isInWallet == true) {
          if (walletTx.timestamp == 0) {
            //did the tx confirm?
            walletTx.newTimestamp = tx['blocktime'] ?? 0;
          }
          if (tx['confirmations'] != null &&
              walletTx.confirmations < tx['confirmations']) {
            //more confirmations?
            walletTx.newConfirmations = tx['confirmations'];
          }
          if (walletTx.broadCasted == false) {
            walletTx.newBroadcasted = true;
          }
        }
      }
    }
    //it's not in wallet yet
    if (!isInWallet) {
      //check if that tx addresses more than one of our addresses
      final utxoInWallet =
          openWallet.utxos.firstWhereOrNull((elem) => elem.hash == tx['txid']);
      final direction = utxoInWallet == null ? 'out' : 'in';

      if (direction == 'in') {
        List voutList = tx['vout'].toList();
        for (final vOut in voutList) {
          final asMap = vOut as Map;
          if (asMap['scriptPubKey']['type'] != 'nulldata') {
            //pre 0.12 backwards compatability
            String addr;
            if (asMap['scriptPubKey']['addresses'].runtimeType == List) {
              addr = asMap['scriptPubKey']['addresses'][0];
            } else {
              addr = asMap['scriptPubKey']['address'];
            }

            if (openWallet.addresses
                    .firstWhereOrNull((element) => element.address == addr) !=
                null) {
              //address is ours, add new tx
              final int txValue = (vOut['value'] * decimalProduct).toInt();

              //increase notification value for addr
              final addrInWallet = openWallet.addresses
                  .firstWhere((element) => element.address == addr);
              addrInWallet.newNotificationBackendCount =
                  addrInWallet.notificationBackendCount + 1;
              openWallet.save();

              //write tx
              openWallet.putTransaction(
                WalletTransaction(
                  txid: tx['txid'],
                  timestamp: tx['blocktime'] ?? 0,
                  value: txValue,
                  fee: 0,
                  address: addr,
                  recipients: {addr: txValue},
                  direction: direction,
                  broadCasted: true,
                  confirmations: tx['confirmations'] ?? 0,
                  broadcastHex: '',
                  opReturn: '',
                ),
              );
            }
          }
        }

        //scan for OP_RETURN messages
        //loop through outputs to find OP_RETURN outputs

        for (final out in Transaction.fromHex(tx['hex']).outputs) {
          final script = Script.decompile(out.scriptPubKey);

          // Find OP_RETURN + push data
          if (script.length == 2 &&
              script[0].match(_opReturn) &&
              script[1] is ScriptPushData) {
            String? parsedMessage;

            final op = script[1] as ScriptPushData;
            try {
              parsedMessage = utf8.decode(op.data);
            } catch (e) {
              //decoding failed
              LoggerWrapper.logError(
                'WalletProvider',
                'putTx',
                e.toString(),
              );
            } finally {
              openWallet.putTransaction(
                WalletTransaction(
                  txid: tx['txid'],
                  timestamp: tx['blocktime'] ?? 0,
                  value: 0,
                  fee: 0,
                  address: 'Metadata',
                  recipients: {'Metadata': 0},
                  direction: direction,
                  broadCasted: true,
                  confirmations: tx['confirmations'] ?? 0,
                  broadcastHex: '',
                  opReturn: parsedMessage ??
                      'There was an error decoding this message',
                ),
              );
            }
          }
        }
      }
      // trigger notification
      if (notify == true) {
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        if (direction == 'in') {
          await flutterLocalNotificationsPlugin.show(
            DateTime.now().millisecondsSinceEpoch ~/ 10000,
            AppLocalizations.instance.translate(
              'notification_title',
              {'walletTitle': openWallet.title},
            ),
            tx['txid'],
            LocalNotificationSettings.platformChannelSpecifics,
            payload: identifier,
          );
        }
      }
    }

    notifyListeners();
    await openWallet.save();
  }

  Future<void> putUtxos({
    required String identifier,
    required String address,
    required List utxos,
  }) async {
    final openWallet = getSpecificCoinWallet(identifier);

    //clear utxos for address
    openWallet.clearUtxo(address);

    //put them in again
    for (final tx in utxos) {
      openWallet.putUtxo(
        WalletUtxo(
          hash: tx['tx_hash'],
          txPos: tx['tx_pos'],
          height: tx['height'],
          value: tx['value'],
          address: address,
        ),
      );
    }

    await updateWalletBalance(identifier);
    await openWallet.save();
    notifyListeners();
  }

  void removeAddress(String identifier, WalletAddress addr) {
    final openWallet = getSpecificCoinWallet(identifier);
    openWallet.removeAddress(addr);
    notifyListeners();
  }

  Future<void> removeWatchOnlyAddress(
    String identifier,
    WalletAddress addr,
  ) async {
    final openWallet = getSpecificCoinWallet(identifier);
    openWallet.removeAddress(addr);

    //clear utxos
    openWallet.clearUtxo(addr.address);

    //remove tx that are related to this address
    final tx = List.from(
      openWallet.transactions
          .where((element) => element.address == addr.address),
    );
    for (final element in tx) {
      openWallet.removeTransaction(element);
    }

    //update balance
    await updateWalletBalance(identifier);

    notifyListeners();
  }

  String reverseString(String input) {
    final items = [];
    for (int i = 0; i < input.length; i++) {
      items.add(input[i]);
    }
    final itemsReversed = [];
    items.asMap().forEach((index, value) {
      if (index % 2 == 0) {
        itemsReversed.insert(0, items[index + 1]);
        itemsReversed.insert(0, value);
      }
    });
    return itemsReversed.join();
  }

  Uint8List seedPhraseUint8List(String words) {
    return bip39.mnemonicToSeed(words);
  }

  Future<void> setHideWallet(String identifier, bool newState) async {
    final openWallet = getSpecificCoinWallet(identifier);
    openWallet.hidden = newState;
    await openWallet.save();
    notifyListeners();
  }

  void setUnusedAddress({
    required String identifier,
    required String address,
  }) {
    _unusedAddressCache[identifier] = address;
    notifyListeners();
  }

  Future<void> updateAddressStatus(
    String identifier,
    String address,
    String? status,
  ) async {
    LoggerWrapper.logInfo(
      'WalletProvider',
      'updateAddressStatus',
      'updating $address to $status',
    );
    //set address to used
    //update status for address
    final openWallet = getSpecificCoinWallet(identifier);
    final addrInWallet = openWallet.addresses
        .firstWhereOrNull((element) => element.address == address);
    if (addrInWallet != null) {
      addrInWallet.newUsed = status == null ? false : true;
      addrInWallet.newStatus = status;

      if (addrInWallet.wif.isEmpty) {
        await getWif(
          identifier: identifier,
          address: address,
        );
      }
    }
    await openWallet.save();
    await generateUnusedAddress(identifier);
  }

  Future<void> updateAddressWatched(
    String identifier,
    String address,
    bool newValue,
  ) async {
    final openWallet = getSpecificCoinWallet(identifier);
    final addr = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    if (addr != null) {
      addr.isWatched = newValue;
    }
    await openWallet.save();
    notifyListeners();
  }

  Future<void> updateBroadcasted(
    String identifier,
    String txId,
  ) async {
    final openWallet = getSpecificCoinWallet(identifier);
    final tx = openWallet.transactions.where(
      (element) => element.txid == txId,
    );
    for (final element in tx) {
      element.broadCasted = true;
      element.resetBroadcastHex();
      element.confirmations = 0;
      await openWallet.save();
    }
  }

  Future<void> updateDueForRescan({
    required String identifier,
    required bool newState,
  }) async {
    final openWallet = getSpecificCoinWallet(identifier);
    openWallet.dueForRescan = newState;

    await openWallet.save();
  }

  void updateOrCreateAddressLabel({
    required String identifier,
    required String address,
    required String label,
  }) {
    final openWallet = getSpecificCoinWallet(identifier);
    final addr = openWallet.addresses.firstWhereOrNull(
      (element) => element.address == address,
    );
    if (addr != null) {
      //user address
      addr.newAddressBookName = label;
    } else {
      //foreign address
      openWallet.addNewAddress = WalletAddress(
        address: address,
        addressBookName: label,
        used: true,
        status: null,
        isOurs: false,
        wif: '',
        isWatchOnly: false,
      );
    }

    openWallet.save();
    notifyListeners();
  }

  Future<void> updateRejected(
    String identifier,
    String txId,
  ) async {
    final openWallet = getSpecificCoinWallet(identifier);
    final tx = openWallet.transactions.firstWhereOrNull(
      (element) => element.txid == txId && element.confirmations != -1,
    );
    if (tx != null) {
      tx.newConfirmations = -1;

      final lockedUtxos =
          openWallet.utxos.where((element) => element.height == -1);
      for (final element in lockedUtxos) {
        //unlock ALL locked utxos after reject
        element.newHeight = 1;
        await openWallet.save();
      }
      await updateWalletBalance(identifier);
    }
    await openWallet.save();
    notifyListeners();
  }

  Future<void> updateWalletBalance(String identifier) async {
    final openWallet = getSpecificCoinWallet(identifier);

    int balanceConfirmed = 0;
    int unconfirmedBalance = 0;

    for (final walletUtxo in openWallet.utxos) {
      if (walletUtxo.height > 0 ||
          openWallet.transactions.firstWhereOrNull(
                (tx) => tx.txid == walletUtxo.hash && tx.direction == 'out',
              ) !=
              null) {
        balanceConfirmed += walletUtxo.value;
      } else {
        unconfirmedBalance += walletUtxo.value;
      }
    }

    openWallet.balance = balanceConfirmed;
    openWallet.unconfirmedBalance = unconfirmedBalance;

    await openWallet.save();
    notifyListeners();
  }

  void updateWalletTitle({
    required String identifier,
    required String newTitle,
  }) {
    final wallet = getSpecificCoinWallet(identifier);
    wallet.title = newTitle;
    notifyListeners();
  }
}
