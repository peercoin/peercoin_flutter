import 'package:coinlib_flutter/coinlib_flutter.dart';

class ROASTWalletPendingSignatureRequest {
  String despositAddress;
  String depositAmount;
  List<int> derivationPath;
  ECCompressedPublicKey selectedGroupKey;

  ROASTWalletPendingSignatureRequest({
    required this.despositAddress,
    required this.depositAmount,
    required this.selectedGroupKey,
    required this.derivationPath,
  });
}
