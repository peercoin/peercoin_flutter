import 'package:coinlib_flutter/coinlib_flutter.dart' as cl;
import 'package:noosphere_roast_client/noosphere_roast_client.dart';

cl.P2TRAddress deriveKeyToTapRootAddress({
  required int threshold,
  required cl.ECCompressedPublicKey groupKey,
  required int index,
  required bool isTestnet,
}) {
  final derivedKeyInfo = HDGroupKeyInfo.master(
    groupKey: groupKey,
    threshold: threshold,
  ).derive(index);

  final derivedPubkey = derivedKeyInfo.groupKey;

  final taproot = cl.Taproot(internalKey: derivedPubkey);
  final address = cl.P2TRAddress.fromTaproot(
    taproot,
    hrp:
        isTestnet ? cl.Network.testnet.bech32Hrp : cl.Network.mainnet.bech32Hrp,
  );
  return address;
}
