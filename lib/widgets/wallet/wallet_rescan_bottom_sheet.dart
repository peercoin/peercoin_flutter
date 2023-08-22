import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class WalletRescanBottomSheet extends StatelessWidget {
  const WalletRescanBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return PeerContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppLocalizations.instance.translate(
              'scan_modal_title',
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
              'wallet_scan_notice_new',
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          PeerButtonBorder(
            text: AppLocalizations.instance.translate(
              'server_settings_alert_cancel',
            ),
            action: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
