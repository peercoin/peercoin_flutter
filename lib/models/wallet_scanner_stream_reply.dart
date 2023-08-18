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
  final (String, int) task;

  WalletScannerStreamReply({
    required this.type,
    required this.message,
    required this.task,
  });
}
