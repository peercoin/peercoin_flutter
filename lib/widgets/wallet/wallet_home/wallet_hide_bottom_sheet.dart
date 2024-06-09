import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class WalletHideBottomSheet extends StatelessWidget {
  final Function action;
  final bool hidden;
  const WalletHideBottomSheet({
    super.key,
    required this.action,
    required this.hidden,
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
              hidden ? 'unhide_wallet' : 'hide_wallet',
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
              hidden ? 'unhide_wallet_description' : 'hide_wallet_description',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 30,
          ),
          PeerButtonBorder(
            text: AppLocalizations.instance.translate(
              hidden ? 'unhide_wallet_action' : 'hide_wallet_action',
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
