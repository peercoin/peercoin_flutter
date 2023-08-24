import 'package:coinlib_flutter/coinlib_flutter.dart';

bool validateAddress(String address, NetworkParams network) {
  try {
    Address.fromString(address, network);
    return true;
  } catch (e) {
    return false;
  }
}
