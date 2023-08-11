import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../providers/encrypted_box_provider.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../widgets/buttons.dart';
import '../../widgets/setup/session_slider.dart';
import 'setup_landing.dart';

class SetupAuthScreen extends StatefulWidget {
  const SetupAuthScreen({Key? key}) : super(key: key);

  @override
  State<SetupAuthScreen> createState() => _SetupAuthScreenState();
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
        centerTitle: true,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SetupLandingScreen.calcContainerHeight(context),
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
                              color: Colors.white,
                              fontSize: 28,
                            ),
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
                                  key: const Key('setupAllowBiometrics'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                                value: _biometricsAllowed,
                                activeColor:
                                    Theme.of(context).colorScheme.background,
                                inactiveThumbColor: Colors.grey,
                                onChanged: (newState) {
                                  if (_biometricsAvailable == false) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.instance.translate(
                                            'setup_pin_no_biometrics',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
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
                  final encryptedBox = context.read<EncryptedBoxProvider>();
                  final settings = context.read<AppSettingsProvider>();
                  final navigator = Navigator.of(context);
                  await screenLockCreate(
                    title: Text(
                      AppLocalizations.instance.translate('authenticate_title'),
                    ),
                    confirmTitle: Text(
                      AppLocalizations.instance
                          .translate('authenticate_confirm_title'),
                    ),
                    context: context,
                    digits: 6,
                    onConfirmed: (matchedText) async {
                      await encryptedBox.setPassCode(matchedText);
                      await settings.init(true);
                      await settings.createInitialSettings(
                        _biometricsAllowed,
                        AppLocalizations.instance.locale.toString(),
                      );
                      navigator.pop();
                      await navigator.pushNamed(Routes.setupDataFeeds);
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
