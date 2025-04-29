import 'package:coinlib_flutter/coinlib_flutter.dart';

class ROASTWalletPendingSignatureRequest {
  String message;
  String despositAddress;
  String depositAmount;
  List<int> derivationPath;
  ECCompressedPublicKey selectedGroupKey;

  ROASTWalletPendingSignatureRequest({
    required this.message,
    required this.despositAddress,
    required this.depositAmount,
    required this.selectedGroupKey,
    required this.derivationPath,
  });
}
