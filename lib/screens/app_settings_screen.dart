import "package:flutter/material.dart";
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/appsettings.dart';
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

  @override
  Widget build(BuildContext context) {
    _settings = context.watch<AppSettings>();
    _biometricsAllowed = _settings.biometricsAllowed ?? false;
    _authenticationOptions = _settings.authenticationOptions ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Authentification",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _biometricsRevealed == false
                  ? TextButton(
                      onPressed: () =>
                          revealAuthOptions(_settings.biometricsAllowed),
                      child: Text(
                          AppLocalizations.instance
                              .translate('app_settings_revealAuthButton'),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)))
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
                    ]),
              Divider(),
              SizedBox(height: 10),
              Text(
                AppLocalizations.instance.translate('app_settings_seed'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _seedPhrase == ""
                  ? TextButton(
                      onPressed: () =>
                          revealSeedPhrase(_settings.biometricsAllowed),
                      child: Text(
                          AppLocalizations.instance
                              .translate('app_settings_revealSeedButton'),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)))
                  : Column(children: [
                      SelectableText(
                        _seedPhrase,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => Share.share(_seedPhrase),
                        child: Text(
                          AppLocalizations.instance
                              .translate('app_settings_shareSeed'),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
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
