import 'package:coinslib/coinslib.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ledger/ledger_interface_dummy.dart'
    if (dart.library.html) '../ledger/ledger_interface.dart';
import '../../ledger/ledger_public_key.dart';
import '../../models/coin_wallet.dart';
import '../../models/wallet_address.dart';

class AddressGenerator {
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

          newAddress = ledgerMode == true
              ? await _getAddressFromLedgerAtPath(path: derivePath)
              : hdWallet.derivePath(derivePath).address;

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

  Future<String> _getAddressFromLedgerAtPath({
    required String path,
  }) async {
    final LedgerPublicKey res = await LedgerInterface().performTransaction(
      future: LedgerInterface().getWalletPublicKey(
        path: path,
      ),
    );
    return res.address;
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
