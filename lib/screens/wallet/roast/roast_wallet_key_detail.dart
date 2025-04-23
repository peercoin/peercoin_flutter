import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:share_plus/share_plus.dart';

class RoastWalletKeyDetailScreen extends StatefulWidget {
  const RoastWalletKeyDetailScreen({super.key});

  @override
  State<RoastWalletKeyDetailScreen> createState() =>
      _RoastWalletKeyDetailScreenState();
}

class _RoastWalletKeyDetailScreenState
    extends State<RoastWalletKeyDetailScreen> {
  bool _initial = true;
  late MapEntry<ECCompressedPublicKey, FrostKeyWithDetails> _frostKeyEntry;

  @override
  void didChangeDependencies() {
    if (_initial) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      _frostKeyEntry = arguments['frostKeyEntry'];

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _shareGroupKey() {
    Share.share(_frostKeyEntry.value.groupKey.hex);
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
                              'roast_wallet_key_detail_participants',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            _frostKeyEntry.value.acceptedAcks.toString(),
                          ),
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
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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

                      const SizedBox(height: 30),

                      // Share Button
                      Center(
                        child: PeerButton(
                          text: AppLocalizations.instance.translate(
                            'roast_wallet_key_detail_share_group_key',
                          ),
                          action: _shareGroupKey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
