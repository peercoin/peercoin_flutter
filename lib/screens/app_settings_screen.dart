import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/screens/about.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/auth.dart';
import 'package:peercoin/widgets/settings_auth.dart';
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
  bool _biometricsAvailable = false;
  String _seedPhrase = '';
  String _lang = '';
  String _defaultWallet = '';
  String _selectedTheme = '';
  bool _languageChangeInfoDisplayed = false;
  AppSettings _settings;
  ActiveWallets _activeWallets;
  List<CoinWallet> _availableWallets = [];
  final List _availableThemes = [
    'system',
    'light',
    'dark',
  ];

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = context.watch<AppSettings>();
      _activeWallets = context.watch<ActiveWallets>();
      _availableWallets = await _activeWallets.activeWalletsValues;
      var localAuth = LocalAuthentication();
      _biometricsAvailable = await localAuth.canCheckBiometrics;
      if (_biometricsAvailable == false) {
        _settings.setBiometricsAllowed(false);
      }
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

  void saveLang(String lang) async {
    await _settings.setSelectedLang(lang);
    if (_languageChangeInfoDisplayed == false) {
      //show notification
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.instance.translate('app_settings_language_restart'),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ));
      setState(() {
        _languageChangeInfoDisplayed = true;
      });
    }
  }

  void saveTheme(String theme) async {
    await _settings.setSelectedTheme(theme);
    //show notification
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        AppLocalizations.instance.translate('app_settings_language_restart'),
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: 2),
    ));
  }

  void saveSnack(context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        AppLocalizations.instance.translate('app_settings_saved_snack'),
        textAlign: TextAlign.center,
      ),
      duration: Duration(seconds: 2),
    ));
  }

  void saveDefaultWallet(String wallet) async {
    _settings.setDefaultWallet(wallet == _settings.defaultWallet ? '' : wallet);
    saveSnack(context);
  }

  @override
  Widget build(BuildContext context) {
    _biometricsAllowed = _settings.biometricsAllowed ?? false;
    _lang =
        _settings.selectedLang ?? AppLocalizations.instance.locale.toString();
    _defaultWallet = _settings.defaultWallet ?? '';
    _selectedTheme = _settings.selectedTheme ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('app_settings_appbar'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AboutScreen()),
              );
            },
          ),
        ],
      ),
      //drawer: AppDrawer(),
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
                        : SettingsAuth(
                            _biometricsAllowed,
                            _biometricsAvailable,
                            _settings,
                            saveSnack,
                            _settings.authenticationOptions,
                          )
                  ]),
              ExpansionTile(
                  title: Text(
                      AppLocalizations.instance.translate('app_settings_seed'),
                      style: Theme.of(context).textTheme.headline6),
                  childrenPadding: EdgeInsets.all(10),
                  children: [
                    _seedPhrase == ''
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
                  ]),
              ExpansionTile(
                title: Text(
                    AppLocalizations.instance.translate('app_settings_theme'),
                    style: Theme.of(context).textTheme.headline6),
                childrenPadding: EdgeInsets.all(10),
                children: _availableThemes.map((theme) {
                  return InkWell(
                    onTap: () => saveTheme(theme),
                    child: ListTile(
                      title: Text(
                        AppLocalizations.instance
                            .translate('app_settings_theme_$theme'),
                      ),
                      leading: Radio(
                        value: theme,
                        groupValue: _selectedTheme,
                        onChanged: (_) => saveTheme(theme),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
