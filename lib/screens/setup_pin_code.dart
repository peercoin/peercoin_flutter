import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/setup_progress.dart';
import 'package:provider/provider.dart';

class SetupPinCodeScreen extends StatefulWidget {
  @override
  _SetupPinCodeScreenState createState() => _SetupPinCodeScreenState();
}

class _SetupPinCodeScreenState extends State<SetupPinCodeScreen> {
  bool _biometricsAllowed = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupProgressIndicator(3),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icon/ppc-icon-white-256.png",
              width: 50,
            ),
            Text(
              AppLocalizations.instance.translate('setup_pin_title'),
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(AppLocalizations.instance.translate('setup_pin'),
                style: TextStyle(color: Colors.white)),
            SwitchListTile(
                title: Text(
                    AppLocalizations.instance
                        .translate('app_settings_biometrics'),
                    style: TextStyle(color: Colors.white)),
                value: _biometricsAllowed,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.grey,
                onChanged: (newState) {
                  setState(() {
                    _biometricsAllowed = newState;
                  });
                }),
            ElevatedButton(
              onPressed: () async {
                await screenLock(
                  title: HeadingTitle(
                      text: AppLocalizations.instance
                          .translate("authenticate_title")),
                  confirmTitle: HeadingTitle(
                      text: AppLocalizations.instance
                          .translate("authenticate_confirm_title")),
                  context: context,
                  correctString: '',
                  digits: 6,
                  confirmation: true,
                  didConfirmed: (matchedText) async {
                    await Provider.of<EncryptedBox>(context, listen: false)
                        .setPassCode(matchedText);

                    AppSettings settings =
                        Provider.of<AppSettings>(context, listen: false);
                    await settings.init();
                    await settings.createInitialSettings(_biometricsAllowed,
                        AppLocalizations.instance.locale.toString());

                    var prefs = await Provider.of<UnencryptedOptions>(context,
                            listen: false)
                        .prefs;
                    await prefs.setBool("setupFinished", true);
                    await Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.WalletList, (_) => false);
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
