import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/models/hive/coin_wallet.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/models/roast_group_export_config.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_participants.dart';
import 'package:peercoin/exceptions/roast_config_exceptions.dart';

class ROASTGroupSetupLanding extends StatefulWidget {
  final ROASTWallet roastWallet;
  final CoinWallet coinWallet;

  const ROASTGroupSetupLanding({
    required this.roastWallet,
    required this.coinWallet,
    super.key,
  });

  @override
  State<ROASTGroupSetupLanding> createState() => _ROASTGroupSetupLandingState();
}

enum ROASTSetupStep { group, pubkey }

class _ROASTGroupSetupLandingState extends State<ROASTGroupSetupLanding> {
  bool _initial = false;
  ROASTSetupStep _step = ROASTSetupStep.group;
  final _groupIdKey = GlobalKey<FormFieldState>();
  final _groupIdController = TextEditingController();
  final _nameKey = GlobalKey<FormFieldState>();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    if (!_initial) {
      _groupIdController.text = widget.roastWallet.groupId;
      _nameController.text = widget.roastWallet.ourName;
      setState(() {
        _initial = true;
      });
    }
    super.didChangeDependencies();
  }

  void _changeStep(ROASTSetupStep step) {
    setState(() {
      _step = step;
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      widget.roastWallet.groupId = _groupIdController.text;
      widget.roastWallet.ourName = _nameController.text;
      _changeStep(ROASTSetupStep.pubkey);
    }
  }

  bool _isImporting = false;
  Map<Identifier, ECCompressedPublicKey>? _importedParticipants;

  Future<void> _importConfiguration() async {
    if (_isImporting) return;

    // Show confirmation dialog
    final bool? shouldImport = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('roast_import_confirm_title'),
          ),
          content: Text(
            AppLocalizations.instance
                .translate('roast_import_confirm_description'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.instance.translate('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                AppLocalizations.instance
                    .translate('roast_import_confirm_button'),
              ),
            ),
          ],
        );
      },
    );

    if (shouldImport != true) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final result = await ROASTGroupExportConfig.importGroupConfiguration();

      // Apply imported configuration to the wallet
      result.applyToROASTWallet(widget.roastWallet);

      // Store imported participants data for the participants screen
      _importedParticipants = result.participants;

      // Update the UI controllers
      _groupIdController.text = result.groupId;
      _nameController.text = widget.roastWallet.ourName;

      // Show success message and proceed to participants screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.instance
                  .translate('roast_import_success')
                  .replaceAll('%count%', result.participantCount.toString()),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _changeStep(ROASTSetupStep.pubkey);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage =
            AppLocalizations.instance.translate('roast_import_error');
        if (e is ROASTConfigException) {
          errorMessage = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == ROASTSetupStep.pubkey) {
      return ROASTGroupSetupParticipants(
        roastWallet: widget.roastWallet,
        coinWallet: widget.coinWallet,
        changeStep: _changeStep,
        importedParticipants: _importedParticipants,
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              child: PeerContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      AppLocalizations.instance
                          .translate('roast_setup_landing_title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('roast_setup_landing_description'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            enabled: widget.roastWallet.clientConfig == null,
                            key: _groupIdKey,
                            autocorrect: false,
                            validator: (value) => value!.isEmpty
                                ? AppLocalizations.instance.translate(
                                    'roast_setup_landing_group_id_input_error',
                                  )
                                : null,
                            controller: _groupIdController,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.group),
                              labelText: AppLocalizations.instance.translate(
                                'roast_setup_landing_group_id_input',
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_setup_landing_group_id_input_hint',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            key: _nameKey,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.instance.translate(
                                  'roast_setup_landing_group_name_input_error',
                                );
                              }
                              return null;
                            },
                            controller: _nameController,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.person),
                              labelText: AppLocalizations.instance.translate(
                                'roast_setup_landing_group_name_input',
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_setup_landing_group_name_input_hint',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_setup_landing_experimental_warning',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          PeerButton(
                            text: AppLocalizations.instance
                                .translate('roast_setup_landing_create_group'),
                            action: () => _save(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          PeerButton(
                            text: _isImporting
                                ? AppLocalizations.instance
                                    .translate('roast_import_importing')
                                : AppLocalizations.instance
                                    .translate('roast_import_button'),
                            disabled: _isImporting,
                            action: () => _importConfiguration(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
