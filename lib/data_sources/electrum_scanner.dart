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

    while (!statusAnswers.containsKey(address)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return statusAnswers[address] != null;
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
