import "package:flutter/material.dart";
import 'package:flutter_screen_lock/functions.dart';
import 'package:peercoin/models/coinwallet.dart';
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
  String _lang = "";
  String _defaultWallet = "";
  bool _languageChangeInfoDisplayed = false;
  Map<String, bool> _authenticationOptions;
  AppSettings _settings;
  ActiveWallets _activeWallets;
  List<CoinWallet> _availableWallets = [];

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = context.watch<AppSettings>();
      _activeWallets = context.watch<ActiveWallets>();
      _availableWallets = await _activeWallets.activeWalletsValues;
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
        title: Text(
          AppLocalizations.instance.translate("authenticate_title_new"),
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        confirmTitle: Text(
          AppLocalizations.instance.translate("authenticate_confirm_title_new"),
          style: TextStyle(
            fontSize: 24,
          ),
        ),
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

  void saveLang(String lang) async {
    await _settings.setSelectedLang(lang);
    if (_languageChangeInfoDisplayed == false) {
      //show notification
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.instance.translate("app_settings_language_restart"),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
      setState(() {
        _languageChangeInfoDisplayed = true;
      });
    }
  }

  void saveDefaultWallet(String wallet) async {
    _settings.setDefaultWallet(wallet == _settings.defaultWallet ? "" : wallet);
  }

  @override
  Widget build(BuildContext context) {
    _biometricsAllowed = _settings.biometricsAllowed ?? false;
    _authenticationOptions = _settings.authenticationOptions ?? false;
    _lang =
        _settings.selectedLang ?? AppLocalizations.instance.locale.toString();
    _defaultWallet = _settings.defaultWallet ?? "";

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
              ExpansionTile(
                title: Text(
                    AppLocalizations.instance
                        .translate('app_settings_language'),
                    style: Theme.of(context).textTheme.headline6),
                childrenPadding: EdgeInsets.all(10),
                children: AppLocalizations.availableLocales.keys.map((lang) {
                  return InkWell(
                    onTap: () => saveLang(lang),
                    child: ListTile(
                      title: Text(AppLocalizations.availableLocales[lang]),
                      leading: Radio(
                        value: lang,
                        groupValue: _lang,
                        onChanged: (_) => saveLang(lang),
                      ),
                    ),
                  );
                }).toList(),
              ),
              ExpansionTile(
                title: Text(
                    AppLocalizations.instance
                        .translate('app_settings_default_wallet'),
                    style: Theme.of(context).textTheme.headline6),
                childrenPadding: EdgeInsets.all(10),
                children: _availableWallets.map((wallet) {
                  return InkWell(
                    onTap: () => saveDefaultWallet(wallet.letterCode),
                    child: ListTile(
                      title: Text(wallet.title),
                      leading: Radio(
                        value: wallet.letterCode,
                        groupValue: _defaultWallet,
                        onChanged: (_) => saveDefaultWallet(wallet.letterCode),
                      ),
                    ),
                  );
                }).toList(),
              ),
              ExpansionTile(
                  title: Text(
                      AppLocalizations.instance
                          .translate('app_settings_auth_header'),
                      style: Theme.of(context).textTheme.headline6),
                  childrenPadding: EdgeInsets.all(10),
                  children: [
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
                                  AppLocalizations.instance.translate(
                                      'app_settings_sendTransaction'),
                                ),
                                value:
                                    _authenticationOptions["sendTransaction"],
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
                              onPressed: () =>
                                  changePIN(_settings.biometricsAllowed),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('app_settings_changeCode'),
                              ),
                            )
                          ]),
                  ]),
              ExpansionTile(
                  title: Text(
                      AppLocalizations.instance.translate('app_settings_seed'),
                      style: Theme.of(context).textTheme.headline6),
                  childrenPadding: EdgeInsets.all(10),
                  children: [
                    _seedPhrase == ""
                        ? ElevatedButton(
                            onPressed: () =>
                                revealSeedPhrase(_settings.biometricsAllowed),
                            child: Text(
                              AppLocalizations.instance
                                  .translate('app_settings_revealSeedButton'),
                            ))
                        : Column(children: [
                            SizedBox(height: 20),
                            SelectableText(
                              _seedPhrase,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Share.share(_seedPhrase),
                              child: Text(
                                AppLocalizations.instance
                                    .translate('app_settings_shareSeed'),
                              ),
                            )
                          ])
                  ])
            ],
          ),
        ),
      ),
    );
  }
}
