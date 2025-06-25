import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

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
    final id = Identifier.fromSeed(ourName);

    // Create participant data in JSON format for QR code
    final participantData = {
      'name': ourName,
      'publicKey': pubKey,
    };
    final participantJson = jsonEncode(participantData);

    return ModalBottomSheetContainer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_details_title',
              ),
              style: TextStyle(
                letterSpacing: 1.4,
                fontSize: 24,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            // Name Section
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_name_title',
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            DoubleTabToClipboard(
              clipBoardData: ourName,
              withHintText: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  ourName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            PeerButton(
              text: AppLocalizations.instance.translate(
                'addressbook_swipe_share',
              ),
              action: () => Share.share(ourName),
            ),
            const SizedBox(
              height: 25,
            ),
            // Identifier Section
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_identifier_title',
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_identifier_description',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            DoubleTabToClipboard(
              clipBoardData: id.toString(),
              withHintText: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  id.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            PeerButton(
              text: AppLocalizations.instance.translate(
                'addressbook_swipe_share',
              ),
              action: () => Share.share(id.toString()),
            ),
            const SizedBox(
              height: 25,
            ),
            // Public Key Section
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_pubkey_title',
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_pubkey_description',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            DoubleTabToClipboard(
              clipBoardData: pubKey,
              withHintText: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  pubKey,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            PeerButton(
              text: AppLocalizations.instance.translate(
                'addressbook_swipe_share',
              ),
              action: () => Share.share(pubKey),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_qr_title',
              ),
              style: TextStyle(
                letterSpacing: 1.4,
                fontSize: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: participantJson,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              AppLocalizations.instance.translate(
                'roast_setup_share_participant_qr_description',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            PeerButton(
              text: AppLocalizations.instance.translate(
                'roast_setup_share_participant_qr_share',
              ),
              action: () => Share.share(participantJson),
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
