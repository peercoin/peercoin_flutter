import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/screens/setup/setup.dart';
import 'package:peercoin/widgets/setup/session_slider.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings.dart';
import '../../providers/encrypted_box.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../widgets/buttons.dart';

class SetupAuthScreen extends StatefulWidget {
  const SetupAuthScreen({Key? key}) : super(key: key);

  @override
  _SetupAuthScreenState createState() => _SetupAuthScreenState();
}

class _SetupAuthScreenState extends State<SetupAuthScreen> {
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
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SetupScreen.calcContainerHeight(context),
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const PeerProgress(
                step: 3,
              ),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width > 1200
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      Image.asset(
                        'assets/img/setup-protection.png',
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const PeerButtonSetupBack(),
                          Text(
                            AppLocalizations.instance
                                .translate('app_settings_auth_header'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 28),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: kIsWeb
                            ? const SetupSessionSlider()
                            : SwitchListTile(
                                title: Text(
                                  AppLocalizations.instance
                                      .translate('app_settings_biometrics'),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                                value: _biometricsAllowed,
                                activeColor: Theme.of(context).backgroundColor,
                                inactiveThumbColor: Colors.grey,
                                onChanged: (newState) {
                                  if (_biometricsAvailable == false) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        AppLocalizations.instance.translate(
                                            'setup_pin_no_biometrics'),
                                        textAlign: TextAlign.center,
                                      ),
                                      duration: const Duration(seconds: 5),
                                    ));
                                  } else {
                                    setState(() {
                                      _biometricsAllowed = newState;
                                    });
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              PeerButtonSetup(
                action: () async {
                  await screenLock(
                    title: HeadingTitle(
                      text: AppLocalizations.instance
                          .translate('authenticate_title'),
                    ),
                    confirmTitle: HeadingTitle(
                      text: AppLocalizations.instance
                          .translate('authenticate_confirm_title'),
                    ),
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
                      await settings.createInitialSettings(
                        _biometricsAllowed,
                        AppLocalizations.instance.locale.toString(),
                      );
                      Navigator.pop(context);
                      await Navigator.of(context)
                          .pushNamed(Routes.SetupDataFeeds);
                    },
                  );
                },
                text: AppLocalizations.instance.translate('setup_create_pin'),
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
