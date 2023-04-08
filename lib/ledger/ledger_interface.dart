// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_util';

import 'ledger_exceptions.dart';
import 'ledger_js_binding.dart';

class LedgerInterface {
  late Object transport;
  late Btc btc; //Ledger JS binding class
  static final Map<String, LedgerInterface> _cache =
      <String, LedgerInterface>{};

  factory LedgerInterface() {
    return _cache.putIfAbsent(
      'ledgerinstance',
      () => LedgerInterface._internal(),
    );
  }
  LedgerInterface._internal();

  Future<void> init() async {
    try {
      final transport = await promiseToFuture(
        transportWebUSBCreate(),
      );
      btc = Btc(transport);
    } catch (e) {
      if (e.toString().contains('TransportOpenUserCancelled')) {
        throw LedgerTransportOpenUserCancelled();
      }
      throw LedgerUnknownException();
    }
  }

  Future<LedgerPublicKey> getWalletPublicKey({
    required String path,
    bool verify = false,
    String format = 'legacy',
  }) async {
    try {
      final walletPublicKey = await promiseToFuture(
        btc.getWalletPublicKey(
          path,
          Options(
            verify: verify,
            format: format,
          ),
        ),
      );
      return LedgerPublicKey(
        publicKey: getProperty(walletPublicKey, 'publicKey'),
        chainCode: getProperty(walletPublicKey, 'chainCode'),
        address: getProperty(walletPublicKey, 'bitcoinAddress'),
      );
    } catch (e) {
      if (e.toString().contains('0x6511')) {
        throw LedgerApplicationNotOpen();
      }
      throw LedgerUnknownException();
    }
  }
}

class LedgerPublicKey {
  final String publicKey;
  final String chainCode;
  final String address;

  LedgerPublicKey({
    required this.publicKey,
    required this.chainCode,
    required this.address,
  });
}

//TODO make it sign https://gist.github.com/miguelmota/62559d02a1b99cb291635de4b224349c