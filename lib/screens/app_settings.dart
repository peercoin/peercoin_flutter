import "package:flutter/material.dart";
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/heading_title.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/providers/encryptedbox.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class AppSettingsScreen extends StatefulWidget {
  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _initial = true;
  bool _biometricsAllowed;
  bool _biometricsRevealed = false;
  String _seedPhrase = "";
  Map<String, bool> _authenticationOptions;
  AppSettings _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      // do things
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void revealSeedPhrase(bool biometricsAllowed) async {
    final seed =
        await Provider.of<ActiveWallets>(context, listen: false).seedPhrase;
    await Auth.requireAuth(
      context,
      biometricsAllowed,
      () => setState(
        () {
          _seedPhrase = seed;
        },
      ),
    );
  }

  void revealAuthOptions(bool biometricsAllowed) async {
    await Auth.requireAuth(
      context,
      biometricsAllowed,
      () => setState(
        () {
          _biometricsRevealed = true;
        },
      ),
    );
  }

  void changePIN(bool biometricsAllowed) async {
    await Auth.requireAuth(
      context,
      biometricsAllowed,
      () async => await screenLock(
        title: HeadingTitle(
            text:
                AppLocalizations.instance.translate("authenticate_title_new")),
        confirmTitle: HeadingTitle(
            text: AppLocalizations.instance
                .translate("authenticate_confirm_title_new")),
        context: context,
        correctString: '',
        digits: 6,
        confirmation: true,
        didConfirmed: (matchedText) async {
          await Provider.of<EncryptedBox>(context, listen: false)
              .setPassCode(matchedText);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              AppLocalizations.instance
                  .translate("authenticate_change_pin_success"),
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _settings = context.watch<AppSettings>();
    _biometricsAllowed = _settings.biometricsAllowed ?? false;
    _authenticationOptions = _settings.authenticationOptions ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('app_settings_appbar'),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                AppLocalizations.instance.translate('app_settings_auth_header'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _biometricsRevealed == false
                  ? ElevatedButton(
                      onPressed: () =>
                          revealAuthOptions(_settings.biometricsAllowed),
                      child: Text(
                        AppLocalizations.instance
                            .translate('app_settings_revealAuthButton'),
                      ))
                  : Column(children: [
                      SwitchListTile(
                          title: Text(
                            AppLocalizations.instance
                                .translate('app_settings_biometrics'),
                          ),
                          value: _biometricsAllowed,
                          onChanged: (newState) {
                            _settings.setBiometricsAllowed(newState);
                          }),
                      SwitchListTile(
                          title: Text(
                            AppLocalizations.instance
                                .translate('app_settings_walletList'),
                          ),
                          value: _authenticationOptions["walletList"],
                          onChanged: (newState) {
                            _settings.setAuthenticationOptions(
                                "walletList", newState);
                          }),
                      SwitchListTile(
                          title: Text(
                            AppLocalizations.instance
                                .translate('app_settings_walletHome'),
                          ),
                          value: _authenticationOptions["walletHome"],
                          onChanged: (newState) {
                            _settings.setAuthenticationOptions(
                                "walletHome", newState);
                          }),
                      SwitchListTile(
                          title: Text(
                            AppLocalizations.instance
                                .translate('app_settings_sendTransaction'),
                          ),
                          value: _authenticationOptions["sendTransaction"],
                          onChanged: (newState) {
                            _settings.setAuthenticationOptions(
                                "sendTransaction", newState);
                          }),
                      SwitchListTile(
                          title: Text(
                            AppLocalizations.instance
                                .translate('app_settings_newWallet'),
                          ),
                          value: _authenticationOptions["newWallet"],
                          onChanged: (newState) {
                            _settings.setAuthenticationOptions(
                                "newWallet", newState);
                          }),
                      ElevatedButton(
                        onPressed: () => changePIN(_settings.biometricsAllowed),
                        child: Text(
                          AppLocalizations.instance
                              .translate('app_settings_changeCode'),
                        ),
                      )
                    ]),
              Divider(),
              SizedBox(height: 10),
              Text(
                AppLocalizations.instance.translate('app_settings_seed'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _seedPhrase == ""
                  ? ElevatedButton(
                      onPressed: () =>
                          revealSeedPhrase(_settings.biometricsAllowed),
                      child: Text(
                        AppLocalizations.instance
                            .translate('app_settings_revealSeedButton'),
                      ))
                  : Column(children: [
                      SelectableText(
                        _seedPhrase,
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: () => Share.share(_seedPhrase),
                        child: Text(
                          AppLocalizations.instance
                              .translate('app_settings_shareSeed'),
                        ),
                      )
                    ])
            ],
          ),
        ),
      ),
    );
  }
}
