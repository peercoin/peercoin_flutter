import 'electrum_backend.dart';

enum ElectrumServerType { ssl, wss }

class ElectrumScanner extends ElectrumBackend {
  ElectrumScanner(super.walletProvider, super.servers);
  Map<String, String?> statusAnswers = {};

  Future<bool> getAddressIsKnown(String address) async {
    final scriptHash =
        super.walletProvider.getScriptHash(super.coinName, address);
    subscribeToScriptHashes({
      address: scriptHash,
    });

    for (var i = 0; i < 100; i++) {
      //will wait 10 seconds in total
      await Future.delayed(const Duration(milliseconds: 100));
      if (statusAnswers.containsKey(address)) {
        return statusAnswers[address] != null;
      }
    }

    //throw timeout exception if no answer was received within 10 seconds
    throw Exception('Timeout');
  }

  @override
  void handleAddressStatus(String address, String? newStatus) async {
    statusAnswers[address] = newStatus;
  }

  @override
  void handleScriptHashSubscribeNotification(
    String? hashId,
    String? newStatus,
  ) {
    // DO NOTHING
  }
}
