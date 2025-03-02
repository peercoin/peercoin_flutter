import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peercoin/tools/generic_address.dart';

void main() {
  group('GenericAddress', () {
    test('fromAsm - P2PKH', () {
      const asm =
          'OP_DUP OP_HASH160 ff9296d92c5efc397d0e0b9ebe94d95a532270c4 OP_EQUALVERIFY OP_CHECKSIG';

      final address = GenericAddress.fromAsm(asm, Network.testnet);
      expect(address is P2PKHAddress, true);
      expect(address.toString(), 'n4pJDAqsagWbouT7G7xRH8548s9pZpQwtG');
    });

    test('fromAsm - P2SH', () {
      const asm =
          'OP_HASH160 1123c89acd257e796c209f6f1914ed999f45076d OP_EQUAL';
      final address = GenericAddress.fromAsm(asm, Network.mainnet);
      expect(address is P2SHAddress, true);
      expect(address.toString(), 'p77CZFn9jvg9waCzKBzkQfSvBBzPH1nRre');
    });

    test('fromASM - P2WSH', () {
      const asm = '0 2ea1d5637bf5b26fc442df1adca762ddd0479b45';
      final address = GenericAddress.fromAsm(asm, Network.mainnet);
      expect(address is P2WSHAddress, true);
      expect(address.toString(), 'pc1q96sa2cmm7kexl3zzmuddefmzmhgy0x69pnp2wv');
    });

    test('fromAsm - Unknown program type', () {
      const asm = 'OP_RETURN';
      expect(
        () => GenericAddress.fromAsm(asm, Network.mainnet),
        throwsException,
      );
    });

    //TODO - Implement P2WPKH, P2WSH and P2TR
  });
}
