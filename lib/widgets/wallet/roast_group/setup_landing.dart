import 'package:flutter/material.dart';
import 'package:peercoin/models/hive/roast_group.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_pubkey.dart';

class ROASTGroupSetupLanding extends StatefulWidget {
  final ROASTGroup roastGroup;
  const ROASTGroupSetupLanding({required this.roastGroup, super.key});

  @override
  State<ROASTGroupSetupLanding> createState() => _ROASTGroupSetupLandingState();
}

enum FrostSetupStep { group, pubkey }

class _ROASTGroupSetupLandingState extends State<ROASTGroupSetupLanding> {
  bool _initial = false;
  FrostSetupStep _step = FrostSetupStep.group;
  final _groupIdKey = GlobalKey<FormFieldState>();
  final _groupIdController = TextEditingController();
  final _serverKey = GlobalKey<FormFieldState>();
  final _serverController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    if (!_initial) {
      _groupIdController.text = widget.roastGroup.groupId;
      _serverController.text = widget.roastGroup.serverUrl;
      setState(() {
        _initial = true;
      });
    }
    super.didChangeDependencies();
  }

  void _changeStep(FrostSetupStep step) {
    setState(() {
      _step = step;
    });
  }

  Future<void> _save() async {
    // TODO try calling server url to see if it is valid

    if (_formKey.currentState!.validate()) {
      // see if ClientConfig is already set
      if (widget.roastGroup.clientConfig != null) {
        // if yes, update the server url (id is readOnly at this point)
        widget.roastGroup.serverUrl = _serverController.text;
      } else {
        // if no, set the server url and create a new ClientConfig
        widget.roastGroup.groupId = _groupIdController.text;
        widget.roastGroup.serverUrl = _serverController.text;
      }
      _changeStep(FrostSetupStep.pubkey);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == FrostSetupStep.pubkey) {
      return ROASTGroupSetupPubkey(
        roastGroup: widget.roastGroup,
        changeStep: _changeStep,
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
                            enabled: widget.roastGroup.clientConfig == null,
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
                            key: _serverKey,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.instance.translate(
                                  'roast_setup_landing_server_url_input_empty',
                                );
                              }
                              if (Uri.tryParse(value) == null) {
                                return AppLocalizations.instance.translate(
                                  'roast_setup_landing_server_url_input_error',
                                );
                              }
                              return null;
                            },
                            controller: _serverController,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.outbond),
                              labelText: AppLocalizations.instance.translate(
                                'roast_setup_landing_server_url_input',
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.instance.translate(
                              'roast_setup_landing_server_url_input_hint',
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
                                .translate('roast_setup_landing_cta'),
                            action: () => _save(),
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