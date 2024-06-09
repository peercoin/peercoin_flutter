import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class WalletDeleteWatchOnlyBottomSheet extends StatelessWidget {
  final Function action;
  const WalletDeleteWatchOnlyBottomSheet({
    super.key,
    required this.action,
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
              'delete_wallet',
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
              'delte_wallet_description',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          PeerButtonBorder(
            text: AppLocalizations.instance.translate(
              'addressbook_swipe_delete',
            ),
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
