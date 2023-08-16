enum WalletScannerMessageType {
  scanStarted,
  newWalletFound,
  newAddressFound,
  scanFinished,
  error,
}

class WalletScannerStreamReply {
  final WalletScannerMessageType type;
  final String message;

  WalletScannerStreamReply({
    required this.type,
    required this.message,
  });
}
