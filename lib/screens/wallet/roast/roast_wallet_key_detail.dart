import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/derive_key_to_taproot_address.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:share_plus/share_plus.dart';

class RoastWalletDetailScrenDTO {
  MapEntry<ECCompressedPublicKey, FrostKeyWithDetails> frostKeyEntry;
  Set<int> derivedKeys;
  Function(ECPublicKey key, int index) deriveNewAddress;
  bool isTestnet;

  RoastWalletDetailScrenDTO({
    required this.frostKeyEntry,
    required this.derivedKeys,
    required this.deriveNewAddress,
    required this.isTestnet,
  });
}

class RoastWalletKeyDetailScreen extends StatefulWidget {
  const RoastWalletKeyDetailScreen({super.key});

  @override
  State<RoastWalletKeyDetailScreen> createState() =>
      _RoastWalletKeyDetailScreenState();
}

class _RoastWalletKeyDetailScreenState
    extends State<RoastWalletKeyDetailScreen> {
  bool _initial = true;
  Set<int> _derivedKeys = {};
  late Function(ECPublicKey key, int index) _deriveNewAddress;
  late MapEntry<ECCompressedPublicKey, FrostKeyWithDetails> _frostKeyEntry;

  @override
  void didChangeDependencies() {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments
          as RoastWalletDetailScrenDTO;
      _frostKeyEntry = arguments.frostKeyEntry;
      _derivedKeys = arguments.derivedKeys;
      _deriveNewAddress = arguments.deriveNewAddress;

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _shareGroupKey() {
    Share.share(_frostKeyEntry.value.groupKey.hex);
  }

  Future<void> _deriveKeyDialog() {
    final textFieldController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate(
              'roast_wallet_key_detail_derived_addresses_cta',
            ),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              textInputAction: TextInputAction.done,
              controller: textFieldController,
              autocorrect: false,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                icon: Icon(
                  Icons.call_split,
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

                // Check if key is already in set
                if (_derivedKeys.contains(intValue)) {
                  return AppLocalizations.instance.translate(
                    'roast_wallet_request_signature_derivation_path_already_exists_error',
                  );
                }

                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                // add to derived keys persistent storage
                final val = int.parse(textFieldController.text);
                _deriveNewAddress(
                  _frostKeyEntry.value.groupKey,
                  val,
                );

                // add locally
                _derivedKeys.add(val);

                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate('snack_copied'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final threshold = _frostKeyEntry.value.keyInfo.group.threshold;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_frostKeyEntry.value.name),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: PeerContainer(
          child: SingleChildScrollView(
            child: _initial
                ? const LoadingIndicator()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_wallet_key_detail_description',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _frostKeyEntry.value.description.isNotEmpty
                                  ? _frostKeyEntry.value.description
                                  : AppLocalizations.instance.translate(
                                      'roast_wallet_open_requests_description_empty',
                                    ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Total Participants Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_wallet_request_dkg_threshold',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(threshold.toString()),
                        ],
                      ),
                      const Divider(),

                      // Group Key Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance
                                .translate('roast_wallet_key_detail_group_key'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SelectableText(
                                  _frostKeyEntry.value.groupKey.hex,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () => _copyToClipboard(
                                  _frostKeyEntry.value.groupKey.hex,
                                ),
                                tooltip: AppLocalizations.instance.translate(
                                  'sign_transaction_step_3_button_alt',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Share Button
                      Center(
                        child: PeerButton(
                          text: AppLocalizations.instance.translate(
                            'roast_wallet_key_detail_share_group_key',
                          ),
                          action: _shareGroupKey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Divider(),

                      // Derived Keys Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_wallet_key_detail_derived_addresses',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _derivedKeys.isEmpty
                              ? Text(
                                  AppLocalizations.instance.translate(
                                    'roast_wallet_key_detail_derived_addresses_empty',
                                  ),
                                )
                              : Column(
                                  children: _derivedKeys.map((key) {
                                    final addr = deriveKeyToTapRootAddress(
                                      groupKey: _frostKeyEntry.value.groupKey,
                                      isTestnet: false,
                                      threshold: threshold,
                                      index: key,
                                    ).toString();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(key.toString()),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: DoubleTabToClipboard(
                                              clipBoardData: addr,
                                              withHintText:
                                                  key == _derivedKeys.last,
                                              child: Text(addr),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_wallet_key_detail_derived_addresses_hint',
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: PeerButton(
                              text: AppLocalizations.instance.translate(
                                'roast_wallet_key_detail_derived_addresses_cta',
                              ),
                              action: () => _deriveKeyDialog(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
