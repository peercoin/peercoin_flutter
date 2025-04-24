import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class RequestSignatureTab extends StatelessWidget {
  RequestSignatureTab({
    required this.roastClient,
    required this.groupSize,
    required this.forceRender,
    super.key,
  });

  final Function forceRender;
  final Client roastClient;
  final int groupSize;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _thresholdController = TextEditingController();

  Future<void> _handeSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FocusScope.of(context).unfocus(); //hide keyboard

      try {
        await roastClient.requestSignatures(
          SignaturesRequestDetails(
            requiredSigs: [],
            expiry: Expiry(const Duration(days: 1)),
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.instance.translate(
                  'roast_wallet_request_dkg_sent_success_snack',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Clear the form fields
        _descriptionController.clear();
        _nameController.clear();
        _thresholdController.clear();

        // Force a re-render of the widget
        forceRender();
      } catch (e) {
        LoggerWrapper.logError(
          'RequestDKGTab',
          'handleRequestDKG',
          e.toString(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.instance.translate(
                  'roast_wallet_request_dkg_sent_error_snack',
                ),
              ),
            ),
          );
        }
      }

      //check for required auth TODO
      // if (_appSettings
      //     .authenticationOptions!['sendTransaction']!) {
      //   await Auth.requireAuth(
      //     context: context,
      //     biometricsAllowed:
      //         _appSettings.biometricsAllowed,
      //     callback: () =>
      //         _showTransactionConfirmation(context),
      //   );
      // } else {
      //   _showTransactionConfirmation(context);
      // }
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
    final bool thresholdDisabled = groupSize == 2;

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
                          'roast_wallet_request_dkg_title',
                        ),
                      ),
                      TextFormField(
                        controller: _nameController,
                        maxLength: 40,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.bookmark,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance.translate(
                            'roast_wallet_request_dkg_name',
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.instance.translate(
                              'roast_wallet_request_dkg_name_empty_error',
                            );
                          }
                          if (value.length < 3) {
                            return AppLocalizations.instance.translate(
                              'roast_wallet_request_dkg_name_too_short_error',
                            );
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'roast_setup_group_member_name_input_hint',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        autocorrect: false,
                        maxLength: 1000,
                        minLines: 2,
                        maxLines: 5,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData('text/plain');
                              _descriptionController.text = data!.text!.trim();
                            },
                            icon: Icon(
                              Icons.paste_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          icon: Icon(
                            Icons.message,
                            color: Theme.of(context).primaryColor,
                          ),
                          labelText: AppLocalizations.instance.translate(
                            'roast_wallet_request_dkg_description',
                          ),
                        ),
                      ),
                      thresholdDisabled
                          ? const SizedBox()
                          : TextFormField(
                              textInputAction: TextInputAction.done,
                              controller: _thresholdController,
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
                                  'roast_wallet_request_dkg_threshold',
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.instance.translate(
                                    'roast_wallet_request_dkg_threshold_empty_error',
                                  );
                                }

                                final int? threshold = int.tryParse(value);
                                if (threshold == null) {
                                  return AppLocalizations.instance.translate(
                                    'roast_wallet_request_dkg_threshold_not_number_error',
                                  );
                                }

                                if (threshold < 2) {
                                  return AppLocalizations.instance.translate(
                                    'roast_wallet_request_dkg_threshold_too_small_error',
                                  );
                                }

                                if (threshold > groupSize) {
                                  return AppLocalizations.instance.translate(
                                      'roast_wallet_request_dkg_threshold_too_large_error',
                                      {
                                        'max': groupSize.toString(),
                                      });
                                }

                                return null;
                              },
                            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          AppLocalizations.instance.translate(
                            thresholdDisabled
                                ? 'roast_wallet_request_dkg_groupsize_equals_two_hint'
                                : 'roast_wallet_request_dkg_threshold_hint',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PeerButton(
                        text: AppLocalizations.instance
                            .translate('roast_wallet_request_dkg_cta'),
                        action: () async => await _handeSubmit(context),
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
