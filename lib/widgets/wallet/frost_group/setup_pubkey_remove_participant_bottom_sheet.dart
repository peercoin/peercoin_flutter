import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class SetupPubkeyRemoveParticipantBottomSheet extends StatelessWidget {
  final Function action;
  final String participantName;

  const SetupPubkeyRemoveParticipantBottomSheet({
    super.key,
    required this.action,
    required this.participantName,
  });

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppLocalizations.instance.translate(
              'frost_setup_group_member_remove',
            ),
            style: TextStyle(
              letterSpacing: 1.4,
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            AppLocalizations.instance.translate(
                'frost_setup_group_member_remove_alert_description', {
              'member': participantName,
            }),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          PeerButtonBorder(
            text: AppLocalizations.instance
                .translate('frost_setup_group_member_remove'),
            action: () => action(),
          ),
          const SizedBox(
            height: 10,
          ),
          PeerButtonBorder(
            text: AppLocalizations.instance.translate(
              'server_settings_alert_cancel',
            ),
            action: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
