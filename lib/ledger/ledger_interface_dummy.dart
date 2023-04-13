import 'ledger_public_key.dart';

class LedgerInterface {
  Future<void> init() {
    return Future.value();
  }

  Future<dynamic> performTransaction({
    required Future future,
  }) async {
    return await future;
  }

  Future<LedgerPublicKey> getWalletPublicKey({
    required String path,
    bool verify = false,
    String format = 'legacy',
  }) async {
    return LedgerPublicKey(
      publicKey: '',
      chainCode: '',
      address: '',
    );
  }
} /* This dummy is required to prevent build time errors since dart:js_util is not availble on native devices */
