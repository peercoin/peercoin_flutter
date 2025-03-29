import 'package:flutter/material.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/roast_group/setup_participants.dart';

class ROASTGroupSetupLanding extends StatefulWidget {
  final ROASTWallet roastClient;
  const ROASTGroupSetupLanding({
    required this.roastClient,
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
      _groupIdController.text = widget.roastClient.groupId;
      _nameController.text = widget.roastClient.ourName;
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
      widget.roastClient.groupId = _groupIdController.text;
      widget.roastClient.ourName = _nameController.text;
      _changeStep(ROASTSetupStep.pubkey);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == ROASTSetupStep.pubkey) {
      return ROASTGroupSetupParticipants(
        roastClient: widget.roastClient,
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
                            enabled: widget.roastClient.clientConfig == null,
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
                          PeerButton(
                            text: AppLocalizations.instance
                                .translate('roast_setup_landing_create_group'),
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
