import 'package:flutter/material.dart';
import 'package:peercoin/screens/app_settings.dart';
import 'package:peercoin/screens/wallet_list.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: (Column(children: [
        AppBar(
          title: Text("Navigation"),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(WalletListScreen.routeName),
          leading: Icon(
            Icons.account_balance_wallet,
          ),
          title: const Text('Wallets'),
        ),
        Divider(), //TODO add
        ListTile(
            leading: Icon(Icons.app_settings_alt),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(AppSettingsScreen.routeName))
      ])),
    );
  }
}
