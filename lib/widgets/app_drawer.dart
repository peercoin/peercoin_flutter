import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  void _launchURL(_url) async {
    await canLaunch(_url)
        ? await launch(
            _url,
          )
        : throw 'Could not launch $_url';
  }

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
            leading: Icon(Icons.shopping_basket),
            title: Text(AppLocalizations.instance.translate('buy_peercoin')),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(
                  AppLocalizations.instance
                      .translate('buy_peercoin_dialog_title'),
                ),
                content: Text(AppLocalizations.instance
                    .translate('buy_peercoin_dialog_content')),
                actions: <Widget>[
                  TextButton.icon(
                      label: Text(AppLocalizations.instance
                          .translate('server_settings_alert_cancel')),
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  TextButton.icon(
                    label: Text(AppLocalizations.instance
                        .translate('jail_dialog_button')),
                    icon: Icon(Icons.check),
                    onPressed: () {
                      _launchURL('https://ppc.lol/buy');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
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
