import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart' as frost;

class ROASTWalletSignatureRequestConfirmationScreenArguments {
  final SignaturesRequest request;
  final frost.Client roastClient;

  const ROASTWalletSignatureRequestConfirmationScreenArguments({
    required this.request,
    required this.roastClient,
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
  bool _initial = true;
  late SignaturesRequest _request;
  late frost.Client _roastClient;

  @override
  void didChangeDependencies() {
    if (_initial) {
      _initial = false;
      final args = ModalRoute.of(context)?.settings.arguments
          as ROASTWalletSignatureRequestConfirmationScreenArguments;
      _request = args.request;
      _roastClient = args.roastClient;

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Request Confirmation'),
      ),
      body: Center(
        child: PeerButton(
          text: 'Confirm Signature Request',
          action: () => _roastClient.acceptSignaturesRequest(
            _request.details.id,
          ),
        ),
      ),
    );
  }
}
