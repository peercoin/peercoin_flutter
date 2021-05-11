import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:share/share.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: (Column(
        children: [
          AppBar(
            title: Text(AppLocalizations.instance.translate('app_navigation')),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(Routes.WalletList),
            leading: Icon(
              Icons.account_balance_wallet,
            ),
            title: Text(AppLocalizations.instance.translate('app_wallets')),
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.app_settings_alt),
              title: Text(AppLocalizations.instance.translate('app_settings')),
              onTap: () => Navigator.of(context)
                  .pushReplacementNamed(Routes.AppSettings)),
          Divider(),
          ListTile(
              leading: Icon(Icons.info),
              title: Text(AppLocalizations.instance.translate('about')),
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed(Routes.About)),
          Divider(),
          ListTile(
            leading: Icon(Icons.share),
            title: Text(AppLocalizations.instance.translate('share_app')),
            onTap: () => Share.share(
                'https://play.google.com/store/apps/details?id=com.coinerella.peercoin'),
          ) //TODO point to peercoin.net when it's on there
        ],
      )),
    );
  }
}
