import "package:coinlib_flutter/coinlib_flutter.dart" as cl;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class RequestSignatureTab extends StatefulWidget {
  const RequestSignatureTab({
    required this.roastClient,
    required this.groupSize,
    required this.forceRender,
    super.key,
  });

  final Function forceRender;
  final Client roastClient;
  final int groupSize;

  @override
  State<RequestSignatureTab> createState() => _RequestSignatureTabState();
}

class _RequestSignatureTabState extends State<RequestSignatureTab> {
  final _formKey = GlobalKey<FormState>();
  final _derivationController = TextEditingController();

  // Track selected group key
  cl.ECCompressedPublicKey? _selectedGroupKey;

  @override
  void initState() {
    super.initState();
    // Initialize with first key if available
    if (widget.roastClient.keys.isNotEmpty) {
      _selectedGroupKey = widget.roastClient.keys.entries.first.key;
    }
  }

  @override
  void dispose() {
    _derivationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext context) async {
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

      try {
        // check https://github.com/peercoin/noosphere_roast_server/blob/master/example/taproot_example.dart#L209
        final derivedKeyInfo = HDGroupKeyInfo.master(
          groupKey: _selectedGroupKey!,
          threshold: 3,
        ).derive(0).derive(0x7fffffff);

        final derivedPubkey = derivedKeyInfo.groupKey;

        print("\nGenerated key ${_selectedGroupKey!.hex}");
        print("HD Derived key ${derivedPubkey.hex}");

        final taproot = cl.Taproot(internalKey: derivedPubkey);
        final testnetAddr = cl.P2TRAddress.fromTaproot(
          taproot,
          hrp: cl.Network.testnet.bech32Hrp,
        );
        final mainnetAddr = cl.P2TRAddress.fromTaproot(
          taproot,
          hrp: cl.Network.mainnet.bech32Hrp,
        );
        print("Testnet Taproot address: $testnetAddr");
        print("Mainnet Taproot address: $mainnetAddr");

        // final trDetails = cl.TaprootKeySignDetails(
        //   tx: unsignedTx,
        //   inputN: 0,
        //   prevOuts: [
        //     cl.Output.fromProgram(cl.CoinUnit.coin.toSats("0.02"), program)
        //   ],
        // );

        // await widget.roastClient.requestSignatures(
        //   SignaturesRequestDetails(
        //     requiredSigs: [
        //       SingleSignatureDetails(
        //         signDetails: SignDetails.scriptSpend(
        //           message:
        //               cl.TaprootSignatureHasher(_messageController.text).hash,
        //         ),
        //         groupKey: _selectedGroupKey!, // Use selected key
        //         hdDerivation: [0, 1],
        //       ),
        //     ],
        //     expiry: Expiry(const Duration(days: 1)),
        //   ),
        // );

        if (context.mounted) {
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
        }

        // Clear the form fields
        _derivationController.clear();

        // Force a re-render of the widget
        widget.forceRender();
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
                        onChanged: hasKeys
                            ? (value) {
                                setState(() {
                                  _selectedGroupKey = value;
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

                      const SizedBox(height: 20),

                      TextFormField(
                        textInputAction: TextInputAction.done,
                        controller: _derivationController,
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.group,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance.translate(
                            'roast_wallet_request_signature_derivation_path',
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.instance.translate(
                              'roast_wallet_request_signature_derivation_path_empty_error',
                            );
                          }
                          // Parse the input value
                          final intValue = int.tryParse(value);
                          if (intValue == null) {
                            return AppLocalizations.instance.translate(
                              'roast_wallet_request_signature_derivation_path_invalid_error',
                            );
                          }

                          // Check if it's within 32-bit unsigned integer range (0 to 2^32-1)
                          if (intValue < 0 || intValue > 0xFFFFFFFF) {
                            return AppLocalizations.instance.translate(
                              'roast_wallet_request_signature_derivation_path_range_error',
                            );
                          }

                          return null;
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'roast_wallet_request_signature_derivation_path_hint',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      PeerButton(
                        text: AppLocalizations.instance
                            .translate('roast_wallet_request_dkg_cta'),
                        action: () async => await _handleSubmit(context),
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
