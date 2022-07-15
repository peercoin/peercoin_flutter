import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mailto/mailto.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../tools/app_localizations.dart';
import '../tools/app_routes.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _initial = true;
  PackageInfo? _packageInfo;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _launchURL(String url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(
            url,
          )
        : throw 'Could not launch $url';
  }

  Future<void> launchMailto() async {
    final mailtoLink = Mailto(
      to: ['hello@app.peercoin.net'],
      subject: 'Peercoin Wallet',
    );
    await launchUrlString('$mailtoLink');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('about'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _packageInfo == null
                  ? Container()
                  : Align(
                      child: PeerContainer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(_packageInfo!.appName),
                            Text(
                              'Version ${_packageInfo!.version} Build ${_packageInfo!.buildNumber}',
                            ),
                            Text(
                              AppLocalizations.instance.translate(
                                'about_developers',
                                {'year': DateFormat.y().format(DateTime.now())},
                              ),
                            ),
                            TextButton(
                              onPressed: () => _launchURL(
                                  'https://github.com/peercoin/peercoin_flutter/blob/main/LICENSE'),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('about_license'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(Routes.changeLog),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('changelog_appbar'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.instance.translate('about_free'),
                            ),
                            TextButton(
                                onPressed: () => _launchURL(
                                    'https://github.com/peercoin/peercoin_flutter'),
                                child: Text(
                                  AppLocalizations.instance
                                      .translate('about_view_source'),
                                  textAlign: TextAlign.center,
                                )),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.instance
                                  .translate('about_data_protection'),
                            ),
                            TextButton(
                              onPressed: () => _launchURL(
                                  'https://github.com/peercoin/peercoin_flutter/blob/main/data_protection.md'),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('about_data_declaration'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.instance
                                  .translate('about_foundation'),
                            ),
                            TextButton(
                              onPressed: () => _launchURL(
                                  'https://www.peercoin.net/foundation'),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('about_foundation_button'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.instance
                                  .translate('about_translate'),
                            ),
                            TextButton(
                              onPressed: () async =>
                                  _launchURL('https://weblate.ppc.lol'),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('about_go_weblate'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.instance
                                  .translate('about_help_or_feedback'),
                            ),
                            TextButton(
                              onPressed: () async => launchMailto(),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('about_send_mail'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.instance
                                  .translate('about_illustrations'),
                            ),
                            TextButton(
                              onPressed: () async =>
                                  _launchURL('https://designs.ai'),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('about_illustrations_button'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
//TODO add URI link to donate to Foundation when P2SH / multisig is ready
}
