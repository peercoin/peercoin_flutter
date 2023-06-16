import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mailto/mailto.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/wallet_provider.dart';
import '../tools/app_localizations.dart';
import '../tools/app_routes.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _initial = true;
  late PackageInfo _packageInfo;
  late WalletProvider _walletProvider;
  late List _listOfAvailableWallets;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _walletProvider = context.read<WalletProvider>();
      _listOfAvailableWallets = _walletProvider.availableWalletKeys;
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
    if (_initial) return const SizedBox();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('about'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                child: PeerContainer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(_packageInfo.appName),
                      Text(
                        'Version ${_packageInfo.version} Build ${_packageInfo.buildNumber}',
                      ),
                      Text(
                        AppLocalizations.instance.translate(
                          'about_developers',
                          {'year': DateFormat.y().format(DateTime.now())},
                        ),
                      ),
                      TextButton(
                        onPressed: () => _launchURL(
                          'https://github.com/peercoin/peercoin_flutter/blob/main/LICENSE',
                        ),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_license',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: () => showLicensePage(context: context),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_show_license',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(Routes.changeLog),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'changelog_appbar',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance.translate(
                          'about_free',
                        ),
                      ),
                      TextButton(
                        onPressed: () => _launchURL(
                          'https://github.com/peercoin/peercoin_flutter',
                        ),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_view_source',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance.translate(
                          'about_data_protection',
                        ),
                      ),
                      TextButton(
                        onPressed: () => _launchURL(
                          'https://github.com/peercoin/peercoin_flutter/blob/main/data_protection.md',
                        ),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_data_declaration',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance.translate(
                          'about_foundation',
                        ),
                      ),
                      if (!kIsWeb)
                        _listOfAvailableWallets.contains('peercoin') &&
                                !Platform.isIOS
                            ? TextButton(
                                onPressed: () async {
                                  final navigator = Navigator.of(context);
                                  final values =
                                      _walletProvider.availableWalletValues;
                                  final ppcWallet = values.firstWhere(
                                    (element) => element.name == 'peercoin',
                                  );

                                  navigator.pushNamed(
                                    Routes.walletHome,
                                    arguments: {
                                      'wallet': ppcWallet,
                                      'pushedAddress':
                                          'p77CZFn9jvg9waCzKBzkQfSvBBzPH1nRre',
                                    },
                                  );
                                },
                                child: Text(
                                  AppLocalizations.instance.translate(
                                    'about_donate_button',
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      TextButton(
                        onPressed: () => _launchURL(
                          'https://www.peercoin.net/foundation',
                        ),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_foundation_button',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance.translate(
                          'about_translate',
                        ),
                      ),
                      TextButton(
                        onPressed: () async => _launchURL(
                          'https://weblate.ppc.lol',
                        ),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_go_weblate',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance.translate(
                          'about_help_or_feedback',
                        ),
                      ),
                      TextButton(
                        onPressed: () async => launchMailto(),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_send_mail',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.instance.translate(
                          'about_illustrations',
                        ),
                      ),
                      TextButton(
                        onPressed: () async => _launchURL(
                          'https://designs.ai',
                        ),
                        child: Text(
                          AppLocalizations.instance.translate(
                            'about_illustrations_button',
                          ),
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
}
