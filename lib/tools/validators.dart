import 'package:coinlib_flutter/coinlib_flutter.dart';

/// Returns true if the address is valid for the given network.
bool validateAddress(String address, Network network) {
  try {
    Address.fromString(address, network);
    return true;
  } catch (e) {
    return false;
  }
}

/// Returns true if the WIF private key is valid.
bool validateWIFPrivKey(String privKey) {
  try {
    WIF.fromString(privKey);
    return true;
  } catch (e) {
    return false;
  }
}
