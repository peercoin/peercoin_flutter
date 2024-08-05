import 'package:flutter/material.dart';
import 'package:peercoin/models/hive/frost_group.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_landing.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_pubkey_remove_participant_bottom_sheet.dart';

class FrostGroupSetupPubkey extends StatefulWidget {
  final Function changeStep;
  final FrostGroup frostGroup;
  const FrostGroupSetupPubkey({
    required this.changeStep,
    required this.frostGroup,
    super.key,
  });

  @override
  State<FrostGroupSetupPubkey> createState() => _FrostGroupSetupPubkeyState();
}

class _FrostGroupSetupPubkeyState extends State<FrostGroupSetupPubkey> {
  void _triggerRemoveParticipantBottomSheet() async {
    // show bottom sheet
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SetupPubkeyRemoveParticipantBottomSheet(
          action: _removeParticipant,
        );
      },
      context: context,
    );

    // participant added, remove bottom sheet
    LoggerWrapper.logInfo(
      'FrostGroupSetupPubkey',
      '_triggerRemoveParticipantBottomSheet',
      'participant added', // TODO log participant added
    );
  }

  void _removeParticipant() {
    // TODO remove participant
    print('hello');
  }

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
                    Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () =>
                              _triggerRemoveParticipantBottomSheet(),
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        tileColor: Theme.of(context).colorScheme.primary,
                        title: Text(
                          "Participant Name",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        subtitle: Text(
                          "ECPubkey",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'frost_setup_group_member_add',
                      ),
                      action: () => _triggerRemoveParticipantBottomSheet(),
                    ),
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