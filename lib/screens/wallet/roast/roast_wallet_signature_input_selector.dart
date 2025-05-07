import 'package:flutter/material.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/marisma_utxo.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/marisma_client.dart';
import 'package:peercoin/widgets/buttons.dart';

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
  UtxoFromMarisma? _selectedUtxo;
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

      // Set first UTXO as selected if available
      if (_utxos.isNotEmpty) {
        _selectedUtxo = _utxos.first;
      }

      _balance = _utxos.fold(
        0,
        (previousValue, element) => previousValue + element.amount,
      );

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

  // Format amount in coins with proper decimal places
  String _formatAmount(int amountInSatoshis) {
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: _walletName,
    );
    return (amountInSatoshis / decimalProduct).toStringAsFixed(
      AvailableCoins.getSpecificCoin(_walletName).fractions,
    );
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
          : Column(
              children: [
                // Address and balance info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.instance.translate(
                          'roast_wallet_request_signature_derived_address',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(_address),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.instance.translate(
                          'roast_wallet_signature_input_selector_balance',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_formatAmount(_balance)} ${AvailableCoins.getSpecificCoin(_walletName).letterCode}',
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Available UTXOs header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.instance.translate(
                      'roast_wallet_signature_input_selector_available_utxos',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                // No UTXOs message
                if (_utxos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.instance.translate(
                          'roast_wallet_signature_input_selector_no_utxos',
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                // UTXO radio list
                Expanded(
                  child: ListView.builder(
                    itemCount: _utxos.length,
                    itemBuilder: (context, index) {
                      final utxo = _utxos[index];
                      final coin = AvailableCoins.getSpecificCoin(_walletName);

                      return RadioListTile<UtxoFromMarisma>(
                        title: Text(
                          '${_formatAmount(utxo.amount)} ${coin.letterCode}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TXID: ${utxo.txid}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'VOUT: ${utxo.vout}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        value: utxo,
                        groupValue: _selectedUtxo,
                        onChanged: (value) {
                          setState(() {
                            _selectedUtxo = value;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Select button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PeerButton(
                    active:
                        _utxos.isEmpty || _selectedUtxo == null ? false : true,
                    action: () {
                      Navigator.of(context).pop(_selectedUtxo);
                    },
                    text: AppLocalizations.instance.translate(
                      'roast_wallet_signature_input_select_utxo',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// TODO allow manual input of txid and vout
