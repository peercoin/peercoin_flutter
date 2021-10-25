import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/screens/setup/setup.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _settings.setNotificationInterval(newState == true ? 15 : 0);
    setState(() {
      _bgSyncdAllowed = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    var correctHeight = height - padding.top - padding.bottom;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        height: correctHeight,
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(20.0),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              PeerProgress(4),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  Image.asset(
                    'assets/img/setup-consent.png',
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PeerButtonSetupBack(),
                      Text(
                        AppLocalizations.instance
                            .translate('setup_price_feed_title'),
                        style: TextStyle(color: Colors.white, fontSize: 28),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SwitchListTile(
                              key: Key('setupApiTickerSwitchKey'),
                              title: Text(
                                AppLocalizations.instance
                                    .translate('setup_price_feed_allow'),
                                style: TextStyle(color: Colors.white),
                              ),
                              value: _dataFeedAllowed,
                              activeColor: Colors.white,
                              inactiveThumbColor: Colors.grey,
                              onChanged: (newState) =>
                                  togglePriceTickerHandler(newState)),
                        ),
                        Text(
                          AppLocalizations.instance
                              .translate('setup_price_feed_description'),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  toggleBGSyncHandler(newState)),
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppLocalizations.instance
                              .translate('setup_bg_sync_description'),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  PeerButton(
                    action: () => _launchURL(
                        'https://github.com/peercoin/peercoin_flutter/blob/main/data_protection.md'),
                    text: AppLocalizations.instance
                        .translate('about_data_declaration'),
                  ),
                  PeerButtonSetup(
                    text: AppLocalizations.instance.translate('setup_finish'),
                    action: () async {
                      var prefs = await Provider.of<UnencryptedOptions>(context,
                              listen: false)
                          .prefs;
                      await prefs.setBool('setupFinished', true);
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.WalletList, (_) => false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
