import 'package:flutter/material.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/models/marisma_utxo.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/marisma_client.dart';

class ROASTWalletSignatureInputSelectorArguments {
  final String address;
  final String walletName;

  const ROASTWalletSignatureInputSelectorArguments({
    required this.address,
    required this.walletName,
  });
}

class ROASTWalletSignatureInputSelector extends StatefulWidget {
  const ROASTWalletSignatureInputSelector({super.key});

  @override
  State<ROASTWalletSignatureInputSelector> createState() =>
      _ROASTWalletSignatureInputSelectorState();
}

class _ROASTWalletSignatureInputSelectorState
    extends State<ROASTWalletSignatureInputSelector> {
  bool _initial = true;
  int _balance = 0;
  List<UtxoFromMarisma> _utxos = [];
  late String _address;
  late String _walletName;
  late MarismaClient _marismaClient;
  late Future<void> Function() _closeMarismaClient;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      final args = ModalRoute.of(context)?.settings.arguments
          as ROASTWalletSignatureInputSelectorArguments;
      _address = args.address;
      _walletName = args.walletName;

      // check against marisma
      final (grpcClient, close) = getMarismaClient(_walletName);
      _marismaClient = grpcClient;
      _closeMarismaClient = close;

      final res = await _marismaClient.getAddressUtxoList(
        AddressListRequest()..address = _address,
      );

      _utxos = UtxoFromMarisma.fromPbList(
        res.utxos,
        _walletName,
      );

      _balance = _utxos.fold(
        0,
        (previousValue, element) => previousValue + element.amount,
      );

      print('Balance: $_balance');
      print('UTXOs: $_utxos');

      setState(() {
        _initial = false;
      });
      super.didChangeDependencies();
    }
  }

  @override
  void dispose() {
    _closeMarismaClient();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 1,
          title: Text(
            AppLocalizations.instance
                .translate('roast_wallet_signature_input_selector_title'),
          ),
        ),
        body: _initial
            ? const Center(child: CircularProgressIndicator())
            : Text('hi'));
  }
}

// TODO allow manual input of txid and vout
