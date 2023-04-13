import 'package:coinslib/coinslib.dart';
import 'package:collection/collection.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ledger/ledger_interface_dummy.dart'
    if (dart.library.html) '../../ledger/ledger_interface.dart';
import '../../../ledger/ledger_public_key.dart';
import '../../../models/coin_wallet.dart';
import '../../../models/wallet_address.dart';

class AddressGenerator {
  Future<String> generateAddressFromPath({
    required HDWallet hdWallet,
    String path = '',
    int account = 0,
    int chain = 0,
    int address = 0,
    bool master = false,
  }) async {
    //check ledger mode
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ledgerMode = prefs.getBool('ledgerMode') ?? false;

    //form path if not provided
    if (path.isEmpty) {
      if (ledgerMode == true) {
        path = "44'/6'/0'/0/$chain";
      } else {
        path = "m/$account'/$chain/$address";
      }
    }

    LoggerWrapper.logInfo(
      'AddressGenerator',
      'generateAddressFromPath',
      'Generating address from path: $path',
    );

    String newAddr = '';
    if (ledgerMode == true) {
      final LedgerPublicKey res = await LedgerInterface().performTransaction(
        future: LedgerInterface().getWalletPublicKey(
          path: path,
        ),
      );
      newAddr = res.address;
    } else {
      newAddr =
          master == true ? hdWallet.address : hdWallet.derivePath(path).address;
    }

    LoggerWrapper.logInfo(
      'AddressGenerator',
      'generateAddressFromPath',
      'newaddr: $newAddr',
    );
    return newAddr;
  }

  Future<String> generateUnusedAddress({
    required CoinWallet openWallet,
    required HDWallet hdWallet,
  }) async {
    //check ledger mode
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ledgerMode = prefs.getBool('ledgerMode') ?? false;

    if (openWallet.addresses.isEmpty) {
      //wallet is brand new - generate new address
      String newAddr = '';
      if (ledgerMode == true) {
        final LedgerPublicKey res = await LedgerInterface().performTransaction(
          future: LedgerInterface().getWalletPublicKey(
            path: "44'/6'/0'/0/0",
          ),
        );
        newAddr = res.address;
      } else {
        newAddr = hdWallet.address;
      }

      //add address to wallet
      openWallet.addNewAddress = WalletAddress(
        address: newAddr,
        addressBookName: '',
        used: false,
        status: '',
        isOurs: true,
        wif: ledgerMode == true ? '' : hdWallet.wif ?? '',
      );
      return newAddr;
    } else {
      //wallet is not brand new, lets find an unused address
      WalletAddress? unusedAddr =
          await _tryFindUnusedAddressInWallet(openWallet: openWallet);

      if (unusedAddr != null) {
        //unused address available
        return unusedAddr.address;
      } else {
        //not empty, but no unused address available -> create new one
        var numberOfOurAddr = _getNumberOfOurAddresses(openWallet: openWallet);
        late String newAddress;
        bool newAddressFound = false;

        while (newAddressFound == false) {
          var derivePath = ledgerMode == true
              ? "44'/6'/0'/0/$numberOfOurAddr"
              : "m/0'/$numberOfOurAddr/0";

          newAddress = await generateAddressFromPath(
            hdWallet: hdWallet,
            path: derivePath,
          );

          final addressInWallet = _tryFindGeneratedAddressInWallet(
            openWallet: openWallet,
            generatedAddress: newAddress,
          );

          if (addressInWallet == null) {
            newAddressFound = true;
          } else {
            //next increment and loop to find a non-existing one
            numberOfOurAddr++;
          }
        }

        openWallet.addNewAddress = WalletAddress(
          address: newAddress,
          addressBookName: '',
          used: false,
          status: '',
          isOurs: true,
          wif: '',
        );

        return newAddress;
      }
    }
  }

  int _getNumberOfOurAddresses({required CoinWallet openWallet}) {
    return openWallet.addresses
        .where((element) => element.isOurs == true)
        .length;
  }

  WalletAddress? _tryFindGeneratedAddressInWallet({
    required CoinWallet openWallet,
    required String generatedAddress,
  }) {
    return openWallet.addresses.firstWhereOrNull(
      (element) => element.address == generatedAddress,
    );
  }

  Future<WalletAddress?> _tryFindUnusedAddressInWallet({
    required CoinWallet openWallet,
  }) async {
    return openWallet.addresses.firstWhereOrNull(
      (element) => element.used == false && element.status.isEmpty,
    );
  }
}
