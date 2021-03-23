import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/providers/options.dart';
import 'package:peercoin/screens/wallet_list.dart';
import 'package:provider/provider.dart';

class SetupPinCodeScreen extends StatelessWidget {
  static const routeName = "/setup-pin";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icon/ppc-icon-white-256.png",
              width: 50,
            ),
            SizedBox(height: 60),
            Text(AppLocalizations.instance.translate('setup_pin'),
                style: TextStyle(color: Colors.white)),
            SizedBox(height: 30),
            TextButton(
              onPressed: () async {
                await screenLock(
                  title: Text("TestTitle"), //TODO
                  confirmTitle: Text("TestConfirm"), //TODO
                  context: context,
                  correctString: '',
                  digits: 6,
                  confirmation: true,
                  didConfirmed: (matchedText) async {
                    Provider.of<EncryptedBox>(context, listen: false)
                        .setPassCode(matchedText);
                    var prefs =
                        await Provider.of<Options>(context, listen: false)
                            .prefs;
                    await prefs.setBool("setupFinished", true);
                    Navigator.popAndPushNamed(
                        context, WalletListScreen.routeName);
                  },
                );
              },
              child: Text(
                AppLocalizations.instance.translate('setup_create_pin'),
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
