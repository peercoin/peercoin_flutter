import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/providers/unencryptedOptions.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/setup_progress.dart';
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

  void toggleHandler(bool newState) {
    _settings.setSelectedCurrency(newState == true ? 'USD' : '');

    setState(() {
      _dataFeedAllowed = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupProgressIndicator(4),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/ppc-icon-white-256.png',
              width: 50,
            ),
            Text(
              AppLocalizations.instance.translate('setup_price_feed_title'),
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              AppLocalizations.instance
                  .translate('setup_price_feed_description'),
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SwitchListTile(
                key: Key('setupApiSwitchKey'),
                title: Text(
                    AppLocalizations.instance
                        .translate('setup_price_feed_allow'),
                    style: TextStyle(color: Colors.white)),
                value: _dataFeedAllowed,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.grey,
                onChanged: (newState) => toggleHandler(newState)),
            PeerButton(
              action: () => _launchURL(
                  'https://github.com/peercoin/peercoin_flutter/blob/main/data_protection.md'),
              text:
                  AppLocalizations.instance.translate('about_data_declaration'),
            ),
            PeerButtonBorder(
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
          ],
        ),
      ),
    );
  }
}
