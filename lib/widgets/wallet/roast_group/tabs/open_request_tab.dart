import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';

enum DialogType {
  accept,
  reject,
}

class OpenRequestTab extends StatelessWidget {
  final Client roastClient;
  final Function forceRender;

  const OpenRequestTab({
    required this.roastClient,
    required this.forceRender,
    super.key,
  });

  void _toggleConfirmationAlert(
    BuildContext context,
    DialogType type,
    Function callback,
  ) {
    // Determine the appropriate strings based on dialog type
    final String titleKey = type == DialogType.accept
        ? 'roast_wallet_dkg_modal_accept_title'
        : 'roast_wallet_dkg_modal_reject_title';

    final String descriptionKey = type == DialogType.accept
        ? 'roast_wallet_dkg_modal_accept_description'
        : 'roast_wallet_dkg_modal_reject_description';

    final String ctaKey = type == DialogType.accept
        ? 'roast_wallet_dkg_modal_accept_cta'
        : 'roast_wallet_dkg_modal_reject_cta';

    final String successSnackKey = type == DialogType.accept
        ? 'roast_wallet_dkg_modal_accept_snack'
        : 'roast_wallet_dkg_modal_reject_snack';

    final String errorSnackKey = type == DialogType.accept
        ? 'roast_wallet_dkg_modal_accept_snack_error'
        : 'roast_wallet_dkg_modal_reject_snack_error';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.instance.translate(titleKey),
        ),
        content: Text(
          AppLocalizations.instance.translate(descriptionKey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              AppLocalizations.instance
                  .translate('server_settings_alert_cancel'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();

              try {
                await callback();
                forceRender();

                // Show success snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.instance.translate(successSnackKey),
                        textAlign: TextAlign.center,
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              } catch (e) {
                // Show error snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.instance.translate(errorSnackKey),
                        textAlign: TextAlign.center,
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: Text(
              AppLocalizations.instance.translate(ctaKey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            Align(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  roastClient.dkgRequests.isEmpty
                      ? Text(
                          AppLocalizations.instance.translate(
                            'roast_wallet_open_requests_empty',
                          ),
                        )
                      : const SizedBox(),
                  ...roastClient.dkgRequests.asMap().entries.map((entry) {
                    final request = entry.value;
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Column(
                          spacing: 1,
                          children: [
                            Text(
                              request.details.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              request.details.description.isEmpty
                                  ? AppLocalizations.instance.translate(
                                      'roast_wallet_open_requests_description_empty',
                                    )
                                  : AppLocalizations.instance.translate(
                                      'roast_wappet_open_requests_description',
                                      {'text': request.details.description},
                                    ),
                            ),
                            Text(
                              AppLocalizations.instance.translate(
                                'roast_wallet_open_requests_threshold',
                                {'n': request.details.threshold.toString()},
                              ),
                            ),
                            Text(
                              AppLocalizations.instance.translate(
                                'roast_wallet_open_requests_expiry',
                                {
                                  'n': request.details.expiry.time
                                      .toString()
                                      .split('.')[0]
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () => _toggleConfirmationAlert(
                                    context,
                                    DialogType.accept,
                                    () => roastClient
                                        .acceptDkg(request.details.name),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => _toggleConfirmationAlert(
                                    context,
                                    DialogType.reject,
                                    () => roastClient
                                        .rejectDkg(request.details.name),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
