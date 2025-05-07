import 'package:coinlib_flutter/coinlib_flutter.dart' as cl;
import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/generated/marisma.pbgrpc.dart';
import 'package:peercoin/models/available_coins.dart';
import 'package:peercoin/models/marisma_utxo.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_signature_input_selector.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/derive_key_to_taproot_address.dart';
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
  int? _selectedDerivationIndex;
  cl.ECCompressedPublicKey? _selectedGroupKey;
  bool _enterRecipient = false;
  final _recipientController = TextEditingController();
  UtxoFromMarisma? _selectedUtxo;

  @override
  void dispose() {
    _recipientController.dispose();
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
        if (res is UtxoFromMarisma) {
          setState(() {
            _enterRecipient = true;
            _selectedUtxo = res;
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
      final taproot = cl.Taproot(internalKey: _selectedGroupKey!);
      final program = cl.P2TR.fromTaproot(taproot);

      final unsignedInput = cl.TaprootKeyInput(
        prevOut: cl.OutPoint.fromHex(
          _selectedUtxo!.txid,
          _selectedUtxo!.vout,
        ), // selected utxo is required at this point
      );
      final unsignedTx = cl.Transaction(
        inputs: [unsignedInput],
        outputs: [
          cl.Output.fromAddress(
            // TODO
            // Gives 0.01 PPC as fee. Use CoinSelection to construct transactions
            // with proper fee handling and input selection.
            cl.CoinUnit.coin.toSats("0.01"),
            cl.Address.fromString(
              _recipientController.text,
              widget.isTestnet ? cl.Network.testnet : cl.Network.mainnet,
            ),
          ),
        ],
      );

      final trDetails = cl.TaprootKeySignDetails(
        tx: unsignedTx,
        inputN: 0,
        prevOuts: [
          cl.Output.fromProgram(
              cl.CoinUnit.coin.toSats("0.02"), program) // TODO
        ],
      );

      // Sign signature hash

      final requestDetails = SignaturesRequestDetails(
        requiredSigs: [
          SingleSignatureDetails(
            signDetails: SignDetails.keySpend(
              message: cl.TaprootSignatureHasher(trDetails).hash,
            ),
            groupKey: _selectedGroupKey!,
            hdDerivation: [1], // TODO
          ),
        ],
        expiry: Expiry(Duration(minutes: 3)), //TODO make this configurable
        metadata: TaprootTransactionSignatureMetadata(
          transaction: unsignedTx,
          signDetails: [trDetails],
        ),
      );

      await widget.roastClient.requestSignatures(requestDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get list of available keys and their details
    final keyEntries = widget.roastClient.keys.entries.toList();
    final bool hasKeys = keyEntries.isNotEmpty;

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
                        onChanged: hasKeys && !_enterRecipient
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
                                !_enterRecipient)
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

                      if (_enterRecipient)
                        Column(
                          children: [
                            const SizedBox(height: 16),

                            // Visual indicator that we're moving to the next step
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(thickness: 2),
                            ),

                            // UTXO info section
                            if (_selectedUtxo != null)
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
                                            'roast_wallet_request_signature_selected_utxo',
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('TXID: ${_selectedUtxo!.txid}'),
                                        Text('VOUT: ${_selectedUtxo!.vout}'),
                                        Text(
                                          'Amount: ${(_selectedUtxo!.amount / AvailableCoins.getDecimalProduct(identifier: widget.walletName)).toStringAsFixed(8)} ${AvailableCoins.getSpecificCoin(widget.walletName).letterCode}',
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
                        action: () async => _enterRecipient
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
