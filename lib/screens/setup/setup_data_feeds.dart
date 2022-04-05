import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/screens/setup/setup.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/app_settings.dart';
import '../../providers/unencrypted_options.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../widgets/buttons.dart';

class SetupDataFeedsScreen extends StatefulWidget {
  const SetupDataFeedsScreen({Key? key}) : super(key: key);

  @override
  _SetupDataFeedsScreenState createState() => _SetupDataFeedsScreenState();
}

class _SetupDataFeedsScreenState extends State<SetupDataFeedsScreen> {
  void _launchURL(_url) async {
    await canLaunch(_url)
        ? await launch(
            _url,
          )
        : throw 'Could not launch $_url';
  }

  bool _dataFeedAllowed = false;
  bool _bgSyncdAllowed = false;
  bool _initial = true;
  late AppSettings _settings;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _settings = Provider.of<AppSettings>(context, listen: false);
      await _settings.init();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void togglePriceTickerHandler(bool newState) {
    _settings.setSelectedCurrency(newState == true ? 'USD' : '');

    setState(() {
      _dataFeedAllowed = newState;
    });
  }

  void toggleBGSyncHandler(bool newState) {
    _settings.setNotificationInterval(newState == true ? 30 : 0);
    setState(() {
      _bgSyncdAllowed = newState;
    });
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
              PeerProgress(4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Image.asset(
                      'assets/img/setup-consent.png',
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PeerButtonSetupBack(),
                        AutoSizeText(
                          AppLocalizations.instance
                              .translate('setup_price_feed_title'),
                          minFontSize: 24,
                          maxFontSize: 28,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SwitchListTile(
                                key: Key('setupApiTickerSwitchKey'),
                                title: Text(
                                  AppLocalizations.instance
                                      .translate('setup_price_feed_allow'),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                value: _dataFeedAllowed,
                                activeColor: Colors.white,
                                inactiveThumbColor: Colors.grey,
                                onChanged: (newState) =>
                                    togglePriceTickerHandler(newState),
                              ),
                            ),
                            PeerExplanationText(
                              AppLocalizations.instance
                                  .translate('setup_price_feed_description'),
                              2,
                            ),
                          ],
                        ),
                      ),
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SwitchListTile(
                                key: Key('setupApiBGSwitchKey'),
                                title: Text(
                                  AppLocalizations.instance
                                      .translate('setup_bg_sync_allow'),
                                  style: TextStyle(color: Colors.white),
                                ),
                                value: _bgSyncdAllowed,
                                activeColor: Colors.white,
                                inactiveThumbColor: Colors.grey,
                                onChanged: (newState) =>
                                    toggleBGSyncHandler(newState),
                              ),
                            ),
                            PeerExplanationText(
                              AppLocalizations.instance
                                  .translate('setup_bg_sync_description'),
                              2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PeerButton(
                      action: () => _launchURL(
                          'https://github.com/peercoin/peercoin_flutter/blob/main/data_protection.md'),
                      text: AppLocalizations.instance
                          .translate('about_data_declaration'),
                    ),
                  ],
                ),
              ),
              PeerButtonSetup(
                text: AppLocalizations.instance.translate('setup_finish'),
                action: () async {
                  var prefs = await Provider.of<UnencryptedOptions>(context,
                          listen: false)
                      .prefs;
                  await prefs.setBool('setupFinished', true);
                  await Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.WalletList, (_) => false);
                },
              ),
              SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
