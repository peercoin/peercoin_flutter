import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../widgets/buttons.dart';
import 'setup.dart';

class SetupLegalScreen extends StatefulWidget {
  const SetupLegalScreen({Key? key}) : super(key: key);

  @override
  _SetupLegalScreenState createState() => _SetupLegalScreenState();
}

class _SetupLegalScreenState extends State<SetupLegalScreen> {
  void _launchURL(String url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(
            url,
          )
        : throw 'Could not launch $url';
  }

  bool _termsAgreed = false;

  void toggleTermsHandler(bool newState) {
    setState(() {
      _termsAgreed = newState;
    });
  }

  double calcHeight(BuildContext context) {
    if (MediaQuery.of(context).size.height < 900) return 900;
    return SetupScreen.calcContainerHeight(context);
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
          height: calcHeight(context),
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const PeerProgress(step: 5),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Image.asset(
                      'assets/img/setup-legal.png',
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const PeerButtonSetupBack(),
                        AutoSizeText(
                          AppLocalizations.instance
                              .translate('setup_legal_title'),
                          minFontSize: 24,
                          maxFontSize: 28,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width > 1200
                            ? MediaQuery.of(context).size.width / 2
                            : MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PeerButton(
                              action: () => _launchURL(
                                  'https://github.com/peercoin/peercoin_flutter/blob/main/LICENSE'),
                              text: AppLocalizations.instance.translate(
                                'setup_legal_license',
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SwitchListTile(
                                key: const Key('setupLegalConsentKey'),
                                title: Text(
                                  AppLocalizations.instance
                                      .translate('setup_legal_switch_tile'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                value: _termsAgreed,
                                activeColor: Colors.white,
                                inactiveThumbColor: Colors.grey,
                                onChanged: (newState) =>
                                    toggleTermsHandler(newState),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PeerButtonSetup(
                text: AppLocalizations.instance.translate('setup_finish'),
                active: _termsAgreed,
                action: () async {
                  if (_termsAgreed == false) return;
                  var prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('setupFinished', true);
                  await Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.walletList, (_) => false);
                },
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
