import 'package:coinlib_flutter/coinlib_flutter.dart';

bool validateAddress(String address, NetworkParams network) {
  try {
    Address.fromString(address, network);
    return true;
  } catch (e) {
    return false;
  }
}

bool validateWIFPrivKey(String privKey) {
  var error = false;
  try {
    WIF.fromString(privKey);
  } catch (e) {
    error = true;
  }
  return error;
}
