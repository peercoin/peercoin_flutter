import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';

class ROASTWalletSignatureRequestConfirmationScreenArguments {
  final SignaturesRequest request;

  const ROASTWalletSignatureRequestConfirmationScreenArguments({
    required this.request,
  });
}

class ROASTWalletSignatureRequestConfirmationScreen extends StatefulWidget {
  const ROASTWalletSignatureRequestConfirmationScreen({super.key});

  @override
  State<ROASTWalletSignatureRequestConfirmationScreen> createState() =>
      _ROASTWalletSignatureRequestConfirmationScreenState();
}

class _ROASTWalletSignatureRequestConfirmationScreenState
    extends State<ROASTWalletSignatureRequestConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
