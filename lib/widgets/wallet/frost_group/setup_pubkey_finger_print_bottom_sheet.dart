import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/service_container.dart';

class SetupPubkeyFingerPrintBottomSheet extends StatelessWidget {
  final Function action;
  final String fingerPrint;

  const SetupPubkeyFingerPrintBottomSheet({
    super.key,
    required this.action,
    required this.fingerPrint,
  });

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetContainer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.instance.translate(
                'frost_setup_group_fingerprint_title',
              ),
              style: TextStyle(
                letterSpacing: 1.4,
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            DoubleTabToClipboard(
              clipBoardData: fingerPrint,
              withHintText: true,
              child: Text(
                fingerPrint,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.instance.translate(
                'frost_setup_group_fingerprint_description',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            PeerButtonBorder(
              text: AppLocalizations.instance
                  .translate('frost_setup_group_fingerprint_cta'),
              action: () => action(),
            ),
            Text(
              AppLocalizations.instance
                  .translate('frost_setup_group_fingerprint_cta_hint'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
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
      ),
    );
  }
}
