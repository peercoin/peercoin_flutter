import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_landing.dart';

class FrostGroupSetupPubkey extends StatefulWidget {
  final Function changeStep;
  const FrostGroupSetupPubkey({required this.changeStep, super.key});

  @override
  State<FrostGroupSetupPubkey> createState() => _FrostGroupSetupPubkeyState();
}

class _FrostGroupSetupPubkeyState extends State<FrostGroupSetupPubkey> {
  void _showFingerprint() {
    // TODO show fingerprint
    print('hello');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              child: PeerContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.changeStep(FrostSetupStep.group);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                          ),
                        ),
                        Text(
                          AppLocalizations.instance
                              .translate('frost_setup_group_title'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('frost_setup_group_description'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('frost_setup_group_hint'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('cards'),
                    const SizedBox(
                      height: 20,
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'frost_setup_group_cta',
                      ),
                      action: () => _showFingerprint(),
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
// 4. On this page a list of other participants is shown with: 1. Name. 2. Identifier and 3. Public key. This list will have a "+" or "Add" button to add a new participant with the ability to edit or remove other participant details.
// 6. After details are updated a new potential GroupConfig will be created and the fingerprint will be shown so that it can be compared against other participant's config to ensure it is the same.
// 7. A "Finish" button will move the state to a completed configuration. An ability to download the configuration details for use on a coordination server will be needed.
// 8. Perhaps the next page should have the options: 1. Connect to server (which will present the full DKG and signing options later). 2. Download configuration (for use on a server). 3. Modify configuration (if configuration is later changed, it goes back to the previous screen).