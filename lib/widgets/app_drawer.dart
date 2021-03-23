import 'package:flutter/material.dart';
import 'package:peercoin/app_localizations.dart';
import 'package:peercoin/screens/app_settings.dart';
import 'package:peercoin/screens/wallet_list.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: (Column(children: [
        AppBar(
          title:
              Text(AppLocalizations.instance.translate('app_navigation', null)),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(WalletListScreen.routeName),
          leading: Icon(
            Icons.account_balance_wallet,
          ),
          title: Text(AppLocalizations.instance.translate('app_wallets', null)),
        ),
        Divider(), //TODO add
        ListTile(
            leading: Icon(Icons.app_settings_alt),
            title:
                Text(AppLocalizations.instance.translate('app_settings', null)),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(AppSettingsScreen.routeName))
      ])),
    );
  }
}
