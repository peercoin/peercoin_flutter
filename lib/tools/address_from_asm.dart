import 'package:coinlib_flutter/coinlib_flutter.dart';

class GenericAddress {
  static Address fromAsm(String asm, Network network) {
    final program = Program.fromAsm(asm);
    if (program is P2PKH) {
      return P2PKHAddress.fromHash(
        program.pkHash,
        version: network.p2pkhPrefix,
      );
    } else if (program is P2SH) {
      return P2SHAddress.fromHash(
        program.scriptHash,
        version: network.p2shPrefix,
      );
    } else if (program is P2WPKH) {
      return P2WPKHAddress.fromHash(
        program.pkHash,
        hrp: network.bech32Hrp,
      );
    } else if (program is P2WSH) {
      return P2WSHAddress.fromHash(program.scriptHash, hrp: network.bech32Hrp);
    } else if (program is P2TR) {
      throw Exception('P2TR not supported here');
    } else {
      throw Exception('Unknown program type');
    }
  }
}
