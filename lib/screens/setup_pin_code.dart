import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/setup_progress.dart';
import 'package:provider/provider.dart';

class SetupPinCodeScreen extends StatefulWidget {
  @override
  _SetupPinCodeScreenState createState() => _SetupPinCodeScreenState();
}

class _SetupPinCodeScreenState extends State<SetupPinCodeScreen> {
  bool _biometricsAllowed = true;
  bool _initial = true;
  bool _biometricsAvailable = false;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      try {
        var localAuth = LocalAuthentication();
        _biometricsAvailable = await localAuth.canCheckBiometrics;
      } catch (e) {
        _biometricsAvailable = false;
      }

      if (_biometricsAvailable == false) {
        _biometricsAllowed = false;
      }
    }
    setState(() {
      _initial = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SetupProgressIndicator(3),
            ),
            Image.asset(
              'assets/images/55-Protection.png',
              height: MediaQuery.of(context).size.height/3,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Security',
                style: TextStyle(color: Colors.white, fontSize: 40),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SwitchListTile(
                      title: Text(
                        AppLocalizations.instance
                            .translate('app_settings_biometrics'),
                        style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),
                      ),
                        value: _biometricsAllowed,
                        activeColor: Theme.of(context).backgroundColor,
                        inactiveThumbColor: Colors.grey,
                        onChanged: (newState) {
                          if (_biometricsAvailable == false) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                AppLocalizations.instance
                                    .translate('setup_pin_no_biometrics'),
                                textAlign: TextAlign.center,
                              ),
                              duration: Duration(seconds: 5),
                            ));
                          } else {
                            setState(() {
                              _biometricsAllowed = newState;
                            });
                          }
                        }),
                  ),
                  PeerButtonBorder(
                    action: () async {
                      await screenLock(
                        title: HeadingTitle(
                            text: AppLocalizations.instance
                                .translate('authenticate_title')),
                        confirmTitle: HeadingTitle(
                            text: AppLocalizations.instance
                                .translate('authenticate_confirm_title')),
                        context: context,
                        correctString: '',
                        digits: 6,
                        confirmation: true,
                        didConfirmed: (matchedText) async {
                          await Provider.of<EncryptedBox>(context, listen: false)
                              .setPassCode(matchedText);

                          var settings =
                          Provider.of<AppSettings>(context, listen: false);
                          await settings.init(true);
                          await settings.createInitialSettings(_biometricsAllowed,
                              AppLocalizations.instance.locale.toString());

                          var prefs = await Provider.of<UnencryptedOptions>(context,
                              listen: false)
                              .prefs;
                          await prefs.setBool('setupFinished', true);
                          await Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.WalletList, (_) => false);
                        },
                      );
                    },
                    text: AppLocalizations.instance.translate('setup_create_pin'),
                  ),
                  SizedBox(height: 8,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
