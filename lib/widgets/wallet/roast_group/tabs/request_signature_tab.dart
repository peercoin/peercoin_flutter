import 'package:coinlib_flutter/coinlib_flutter.dart' as cl;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/marisma_utxo.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_signature_input_selector.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/roast/derive_key_to_taproot_address.dart';
import 'package:peercoin/tools/roast/generate_taproot_signature_request_details.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/tools/validators.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class RequestSignatureTab extends StatefulWidget {
  const RequestSignatureTab({
    required this.roastClient,
    required this.threshold,
    required this.forceRender,
    required this.isTestnet,
    required this.walletName,
    required this.marismaClient,
    required this.derivedKeys,
    super.key,
  });

  final Function forceRender;
  final Client roastClient;
  final int threshold;
  final bool isTestnet;
  final String walletName;
  final MarismaClient marismaClient;
  final Map<cl.ECPublicKey, Set<int>> derivedKeys;

  @override
  State<RequestSignatureTab> createState() => _RequestSignatureTabState();
}

class _RequestSignatureTabState extends State<RequestSignatureTab> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  bool _enterRecipientAndAmount = false;
  int? _selectedDerivationIndex;
  cl.ECCompressedPublicKey? _selectedGroupKey;
  List<UtxoFromMarisma>? _selectedUtxos;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize with first key if available
    if (widget.roastClient.keys.isNotEmpty) {
      _selectedGroupKey = widget.roastClient.keys.entries.first.key;
      // Initialize derivation index if available for this key
      final indices = _getDerivedIndicesForKey(_selectedGroupKey);
      if (indices.isNotEmpty) {
        _selectedDerivationIndex = indices.first;
      }
    }
  }

  List<int> _getDerivedIndicesForKey(cl.ECCompressedPublicKey? key) {
    if (key == null) return [];

    // Look up derivation indices for this key
    final indices = widget.derivedKeys[key]?.toList() ?? [];
    return indices..sort(); // Sort indices for better display
  }

  String _getAddressForDerivation(cl.ECCompressedPublicKey key, int index) {
    // Derive the taproot address
    final taprootAddress = deriveKeyToTapRootAddress(
      groupKey: key,
      index: index,
      threshold: widget.threshold,
      isTestnet: widget.isTestnet,
    );
    return taprootAddress.toString();
  }

  Future<void> _handleSubmitOfGroupKeyAndDerivedAddress(
    BuildContext context,
  ) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus(); //hide keyboard

      // Validate that a key is selected
      if (_selectedGroupKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.instance.translate(
                'roast_wallet_request_signature_no_key_error',
              ),
            ),
          ),
        );
        return;
      }

      if (_selectedDerivationIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.instance.translate(
                'roast_wallet_request_signature_no_derivation_error',
              ),
            ),
          ),
        );
        return;
      }

      try {
        final res = await Navigator.of(context).pushNamed(
          Routes.roastWalletSignatureInputSelector,
          arguments: ROASTWalletSignatureInputSelectorArguments(
            address: _getAddressForDerivation(
              _selectedGroupKey!,
              _selectedDerivationIndex!,
            ),
            walletName: widget.walletName,
          ),
        );
        if (res is List<UtxoFromMarisma>) {
          setState(() {
            _enterRecipientAndAmount = true;
            _selectedUtxos = res;
          });
        }
      } catch (e) {
        LoggerWrapper.logError(
          'RequestSignatureTab',
          'handleSubmit',
          e.toString(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.instance.translate(
                  'roast_wallet_request_signature_error_snack',
                ),
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate(
              'send_errors_solve',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _handleRequestSignature(BuildContext ctx) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus(); //hide keyboard

      // we have everything we need at this point
      final double parsedAmount = double.parse(_amountController.text);
      final decimalProduct =
          AvailableCoins.getDecimalProduct(identifier: widget.walletName);
      final amountInSatoshis = (parsedAmount * decimalProduct).round();

      final details = await generateTaprootSignatureRequestDetails(
        groupKey: _selectedGroupKey!,
        groupKeyIndex: _selectedDerivationIndex!,
        selectedUtxos: _selectedUtxos!,
        recipientAddress: _recipientController.text,
        txAmount: BigInt.from(amountInSatoshis),
        expiry: const Duration(
          days: 1,
        ), // TODO: Use the actual expiry from UI
        coinIdentifier: widget.walletName,
        threshold: widget.threshold,
      );

      await widget.roastClient.requestSignatures(details);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.instance.translate(
                'roast_wallet_request_signature_success_snack',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );

        // Reset the form
        setState(() {
          _enterRecipientAndAmount = false;
          _selectedUtxos = null;
          _recipientController.clear();
          _amountController.clear();
        });

        widget.forceRender();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get list of available keys and their details
    final keyEntries = widget.roastClient.keys.entries.toList();
    final bool hasKeys = keyEntries.isNotEmpty;
    final decimalProduct =
        AvailableCoins.getDecimalProduct(identifier: widget.walletName);

    return Stack(
      children: [
        ListView(
          children: [
            Align(
              child: PeerContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PeerServiceTitle(
                        title: AppLocalizations.instance.translate(
                          'roast_wallet_request_signature_title',
                        ),
                      ),

                      // Group key dropdown
                      DropdownButtonFormField<cl.ECCompressedPublicKey>(
                        value: _selectedGroupKey,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.key,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance.translate(
                            'roast_wallet_request_signature_group_key',
                          ),
                        ),
                        hint: Text(
                          AppLocalizations.instance.translate(
                            'roast_wallet_request_signature_select_key',
                          ),
                        ),
                        isExpanded: true,
                        items: keyEntries.map((entry) {
                          return DropdownMenuItem<cl.ECCompressedPublicKey>(
                            value: entry.key,
                            child: Text(
                              entry.value.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: hasKeys && !_enterRecipientAndAmount
                            ? (value) {
                                setState(() {
                                  _selectedGroupKey = value;
                                  // Reset and update derived address when group key changes
                                  final indices =
                                      _getDerivedIndicesForKey(value);
                                  _selectedDerivationIndex =
                                      indices.isNotEmpty ? indices.first : null;
                                });
                              }
                            : null,
                        validator: (value) {
                          if (value == null) {
                            return AppLocalizations.instance.translate(
                              'roast_wallet_request_signature_group_key_empty_error',
                            );
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Derived address dropdown
                      DropdownButtonFormField<int>(
                        value: _selectedDerivationIndex,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.account_balance_wallet,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance.translate(
                            'roast_wallet_request_signature_derived_address',
                          ),
                        ),
                        hint: Text(
                          AppLocalizations.instance.translate(
                            'roast_wallet_request_signature_select_address',
                          ),
                        ),
                        isExpanded: true,
                        items: _getDerivedIndicesForKey(_selectedGroupKey)
                            .map((index) {
                          final address = _selectedGroupKey != null
                              ? _getAddressForDerivation(
                                  _selectedGroupKey!,
                                  index,
                                )
                              : '';

                          return DropdownMenuItem<int>(
                            value: index,
                            child: Tooltip(
                              message: address,
                              child: Text(
                                '${index.toString()} - $address',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (_selectedGroupKey != null &&
                                _getDerivedIndicesForKey(_selectedGroupKey)
                                    .isNotEmpty &&
                                !_enterRecipientAndAmount)
                            ? (value) {
                                setState(() {
                                  _selectedDerivationIndex = value;
                                });
                              }
                            : null,
                        validator: (value) {
                          if (value == null) {
                            return AppLocalizations.instance.translate(
                              'roast_wallet_request_signature_derived_address_empty_error',
                            );
                          }
                          return null;
                        },
                      ),

                      if (_enterRecipientAndAmount)
                        Column(
                          children: [
                            const SizedBox(height: 16),

                            // Visual indicator that we're moving to the next step
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(thickness: 2),
                            ),

                            // UTXO info section
                            if (_selectedUtxos != null &&
                                _selectedUtxos!.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.instance.translate(
                                            'roast_wallet_request_signature_selected_utxos_summary',
                                            {
                                              'count': _selectedUtxos!.length
                                                  .toString(),
                                            },
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppLocalizations.instance.translate(
                                            'roast_wallet_request_signature_total_amount',
                                            {
                                              'amount': (_selectedUtxos!.fold(
                                                        0,
                                                        (sum, utxo) =>
                                                            sum + utxo.amount,
                                                      ) /
                                                      AvailableCoins
                                                          .getDecimalProduct(
                                                        identifier:
                                                            widget.walletName,
                                                      ))
                                                  .toStringAsFixed(8),
                                              'letterCode': AvailableCoins
                                                  .getSpecificCoin(
                                                widget.walletName,
                                              ).letterCode,
                                            },
                                          ),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Recipient address field
                            TextFormField(
                              controller: _recipientController,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    var data =
                                        await Clipboard.getData('text/plain');
                                    _recipientController.text =
                                        data!.text!.trim();
                                  },
                                  icon: Icon(
                                    Icons.paste_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.send,
                                  color: Theme.of(context).primaryColor,
                                ),
                                labelText: AppLocalizations.instance.translate(
                                  'roast_wallet_request_signature_recipient_address',
                                ),
                                hintText: AppLocalizations.instance.translate(
                                  'roast_wallet_request_signature_recipient_address_hint',
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.instance.translate(
                                    'roast_wallet_request_signature_recipient_empty_error',
                                  );
                                }

                                if (validateAddress(
                                      value,
                                      widget.isTestnet
                                          ? cl.Network.testnet
                                          : cl.Network.mainnet,
                                    ) !=
                                    true) {
                                  return AppLocalizations.instance.translate(
                                    'send_invalid_address',
                                  );
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      if (_enterRecipientAndAmount)

                        // Amount input field
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.attach_money,
                              color: Theme.of(context).primaryColor,
                            ),
                            labelText: AppLocalizations.instance.translate(
                              'send_amount',
                            ),
                            suffixText: AvailableCoins.getSpecificCoin(
                              widget.walletName,
                            ).letterCode,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.instance.translate(
                                'send_enter_amount',
                              );
                            }

                            // Parse and validate the amount
                            final double? parsedAmount = double.tryParse(value);
                            if (parsedAmount == null || parsedAmount <= 0) {
                              return AppLocalizations.instance.translate(
                                'send_amount_small',
                              );
                            }

                            if (parsedAmount >
                                _selectedUtxos!.fold(
                                      0,
                                      (sum, utxo) => sum + utxo.amount,
                                    ) /
                                    decimalProduct) {
                              return AppLocalizations.instance.translate(
                                'send_amount_exceeds',
                              );
                            }

                            return null;
                          },
                        ),

                      if (_selectedGroupKey != null &&
                          _getDerivedIndicesForKey(_selectedGroupKey).isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            AppLocalizations.instance.translate(
                              'roast_wallet_request_signature_no_derived_addresses',
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      PeerButton(
                        text: AppLocalizations.instance
                            .translate('roast_wallet_request_dkg_cta'),
                        action: () async => _enterRecipientAndAmount
                            ? await _handleRequestSignature(context)
                            : await _handleSubmitOfGroupKeyAndDerivedAddress(
                                context,
                              ),
                        disabled: !hasKeys,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
