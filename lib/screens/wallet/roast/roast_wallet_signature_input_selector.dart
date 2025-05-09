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
  List<UtxoFromMarisma> _selectedUtxos = [];
  late String _address;
  late String _walletName;
  late MarismaClient _marismaClient;
  late Future<void> Function() _closeMarismaClient;

  int get _selectedAmount =>
      _selectedUtxos.fold(0, (prev, utxo) => prev + utxo.amount);

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

      // Initialize selected UTXOs as empty list
      _selectedUtxos = [];

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

  // Toggle selection of a UTXO
  void _toggleUtxoSelection(UtxoFromMarisma utxo) {
    setState(() {
      if (_selectedUtxos.contains(utxo)) {
        _selectedUtxos.remove(utxo);
      } else {
        _selectedUtxos.add(utxo);
      }
    });
  }

  // Select all UTXOs
  void _selectAllUtxos() {
    setState(() {
      _selectedUtxos = List.from(_utxos);
    });
  }

  // Clear all selected UTXOs
  void _clearSelection() {
    setState(() {
      _selectedUtxos = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final coin = AvailableCoins.getSpecificCoin(_walletName);

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
                        '${_formatAmount(_balance)} ${coin.letterCode}',
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Selection info with actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Selected amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_wallet_signature_input_selector_selected',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_formatAmount(_selectedAmount)} ${coin.letterCode}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Selection actions
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _utxos.isEmpty ? null : _selectAllUtxos,
                            icon: const Icon(Icons.select_all),
                            label: Text(
                              AppLocalizations.instance.translate(
                                'roast_wallet_signature_input_selector_select_all',
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                _selectedUtxos.isEmpty ? null : _clearSelection,
                            icon: const Icon(Icons.clear_all),
                            label: Text(
                              AppLocalizations.instance.translate(
                                'roast_wallet_signature_input_selector_clear',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

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

                // UTXO checkbox list
                Expanded(
                  child: ListView.builder(
                    itemCount: _utxos.length,
                    itemBuilder: (context, index) {
                      final utxo = _utxos[index];

                      return CheckboxListTile(
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
                              'TXID: ${utxo.txid.substring(0, 8)}...${utxo.txid.substring(utxo.txid.length - 8)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'VOUT: ${utxo.vout}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        value: _selectedUtxos.contains(utxo),
                        onChanged: (_) => _toggleUtxoSelection(utxo),
                        secondary: Icon(
                          Icons.account_balance_wallet,
                          color: _selectedUtxos.contains(utxo)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).disabledColor,
                        ),
                      );
                    },
                  ),
                ),

                // Select button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PeerButton(
                    active: _selectedUtxos.isNotEmpty,
                    action: () {
                      Navigator.of(context).pop(_selectedUtxos);
                    },
                    text: AppLocalizations.instance.translate(
                      'roast_wallet_signature_input_selector_use_selected',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
// TODO allow manual input of txid and vout
// TODO don't allow selection of UTXOs under dust limit
