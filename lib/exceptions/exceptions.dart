class CantPayForFeesException implements Exception {
  int feesMissing;
  CantPayForFeesException(this.feesMissing);
}
