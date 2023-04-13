class LedgerApplicationNotOpen implements Exception {
  LedgerApplicationNotOpen();
}

class LedgerUnknownException implements Exception {
  LedgerUnknownException();
}

class LedgerTransportOpenUserCancelled implements Exception {
  LedgerTransportOpenUserCancelled();
}

class LedgerTimeoutException implements Exception {
  LedgerTimeoutException();
}

class LedgerTransactionException implements Exception {
  final String cause;
  final Type baseExceptionType;
  LedgerTransactionException(this.cause, this.baseExceptionType);
}
