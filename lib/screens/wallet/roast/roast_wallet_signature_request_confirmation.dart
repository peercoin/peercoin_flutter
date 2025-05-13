import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/generic_address.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import '../transaction_details.dart';

class ROASTWalletSignatureRequestConfirmationScreenArguments {
  final SignaturesRequest request;
  final Client roastClient;
  final String walletName;

  const ROASTWalletSignatureRequestConfirmationScreenArguments({
    required this.request,
    required this.roastClient,
    required this.walletName,
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
  bool _isLoading = false;
  late SignaturesRequest _request;
  late Client _roastClient;
  late Transaction _transaction;
  late SignaturesRequestId _requestId;
  late String _walletName;
  late String _coinLetterCode;
  late int _decimalProduct;
  Map<String, int> _recipients = {};
  int _totalAmount = 0;
  int _fee = 0;

  @override
  void didChangeDependencies() {
    if (_initial) {
      final args = ModalRoute.of(context)?.settings.arguments
          as ROASTWalletSignatureRequestConfirmationScreenArguments;
      _request = args.request;
      _roastClient = args.roastClient;
      _requestId = _request.details.id;

      final metadata =
          _request.details.metadata as TaprootTransactionSignatureMetadata;
      _transaction = metadata.transaction;

      _walletName = args.walletName;
      final coin = AvailableCoins.getSpecificCoin(_walletName);
      _coinLetterCode = coin.letterCode;
      _decimalProduct =
          AvailableCoins.getDecimalProduct(identifier: _walletName);

      // Process transaction details
      _processTransactionDetails();

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _processTransactionDetails() {
    // Calculate total amount
    _totalAmount = 0;
    _recipients = {};

    for (var output in _transaction.outputs) {
      String address;

      // Get the amount in satoshis
      final amount = output.value.toInt();

      try {
        if (output.scriptPubKey.isNotEmpty) {
          try {
            final networkType =
                _coinLetterCode == 'tPPC' ? Network.testnet : Network.mainnet;

            // Check for OP_RETURN first (byte 0 is 0x6a)
            if (output.scriptPubKey.isNotEmpty &&
                output.scriptPubKey[0] == 0x6a) {
              address = 'OP_RETURN Data';
            } else {
              try {
                // Get the program from scriptPubKey
                final program = Program.decompile(output.scriptPubKey);

                final genericAddress =
                    GenericAddress.fromProgram(program, networkType);
                address = genericAddress.toString();
              } catch (e) {
                throw Exception('Unsupported script program type');
              }
            }
          } catch (e) {
            // Fallback for scripts that can't be parsed with GenericAddress
            final scriptBytes = output.scriptPubKey;
            if (scriptBytes.isNotEmpty && scriptBytes[0] == 0x6a) {
              // OP_RETURN data
              address = 'OP_RETURN Data';
            } else {
              // Default fallback
              address = 'Output ${_transaction.outputs.indexOf(output) + 1}';
            }
          }
        } else {
          address = 'Output ${_transaction.outputs.indexOf(output) + 1}';
        }
      } catch (e) {
        // Default fallback
        address = 'Output ${_transaction.outputs.indexOf(output) + 1}';
      }

      // Add to recipients map
      if (_recipients.containsKey(address)) {
        _recipients[address] = _recipients[address]! + amount;
      } else {
        _recipients[address] = amount;
      }

      // Add to total amount
      _totalAmount += amount;
    }

    // Get data from the TaprootTransactionSignatureMetadata
    final metadata =
        _request.details.metadata as TaprootTransactionSignatureMetadata;

    // If sign details contain prevOuts, we can calculate actual inputs
    if (metadata.signDetails.isNotEmpty &&
        metadata.signDetails[0].prevOuts.isNotEmpty) {
      int inputValue = 0;
      for (var detail in metadata.signDetails) {
        for (var prevOut in detail.prevOuts) {
          inputValue += prevOut.value.toInt();
        }
      }

      // Calculate more accurate fee if we know the input value
      if (inputValue > 0) {
        _fee = inputValue - _totalAmount;
      }
    } else {
      // Fallback fee calculation
      // Based on transaction size/weight
      _fee = (_transaction.toString().length * 0.01).ceil();
    }

    // Ensure fee is never negative
    _fee = _fee < 0 ? 0 : _fee;
  }

  List<Widget> _renderRecipients() {
    List<Widget> list = [];

    _recipients.forEach(
      (addr, value) => list.add(
        const TransactionDetails().renderRow(
          addr,
          value / _decimalProduct,
          _coinLetterCode,
        ),
      ),
    );
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (_initial) {
      return const Center(child: CircularProgressIndicator());
    }

    // Create a simplified transaction identifier
    final requestIdString = bytesToHex(_requestId.toBytes());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('send_confirm_transaction'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Request ID: $requestIdString',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _initial
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Align(
                      child: PeerContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.instance
                                      .translate('tx_value'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SelectableText(
                                      '${_totalAmount / _decimalProduct} $_coinLetterCode',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.instance.translate('tx_fee'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SelectableText(
                                      '${_fee / _decimalProduct} $_coinLetterCode',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.instance
                                      .translate('send_total_amount'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SelectableText(
                                      '${(_totalAmount + _fee) / _decimalProduct} $_coinLetterCode',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.instance
                                      .translate('tx_recipients'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ..._renderRecipients(),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? SizedBox(
                    width: MediaQuery.of(context).size.width > 1200
                        ? MediaQuery.of(context).size.width / 3
                        : MediaQuery.of(context).size.width / 2,
                    child: const LoadingIndicator(),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: PeerButton(
                          text: AppLocalizations.instance
                              .translate('roast_wallet_dkg_modal_reject_cta'),
                          action: () async {
                            setState(() => _isLoading = true);
                            try {
                              await _roastClient
                                  .rejectSignaturesRequest(_requestId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.instance.translate(
                                        'roast_wallet_signature_request_rejected',
                                      ),
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.instance.translate(
                                        'roast_wallet_signature_request_error',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PeerButton(
                          text: AppLocalizations.instance
                              .translate('send_confirm_send'),
                          action: () async {
                            setState(() => _isLoading = true);
                            try {
                              await _roastClient
                                  .acceptSignaturesRequest(_requestId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.instance.translate(
                                        'roast_wallet_signature_request_accepted',
                                      ),
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.instance.translate(
                                        'roast_wallet_signature_request_error',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
