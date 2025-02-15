import 'package:flutter/material.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/service_container.dart';

class SetupParticipantsSharePubKeyBottomSheet extends StatelessWidget {
  final Function action;
  final String pubKey;
  final String ourName;

  const SetupParticipantsSharePubKeyBottomSheet({
    super.key,
    required this.action,
    required this.pubKey,
    required this.ourName,
  });
  @override
  Widget build(BuildContext context) {
    final id = Identifier.fromString(ourName);

    return ModalBottomSheetContainer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_group_share_pubkey_id',
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
              clipBoardData: id.toString(),
              withHintText: true,
              child: Text(
                id.toString(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(ourName),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_group_share_pubkey_key',
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
              clipBoardData: pubKey,
              withHintText: true,
              child: Text(
                pubKey,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            PeerButtonBorder(
              text: AppLocalizations.instance.translate(
                'wallet_scan_close',
              ),
              action: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO Show QR button
