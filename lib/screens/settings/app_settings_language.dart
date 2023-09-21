import 'package:flutter/material.dart';
import 'package:peercoin/screens/language_selector.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings_provider.dart';
import '../../tools/app_localizations.dart';

class AppSettingsLanguageScreen extends StatefulWidget {
  const AppSettingsLanguageScreen({super.key});

  @override
  State<AppSettingsLanguageScreen> createState() =>
      _AppSettingsLanguageScreenState();
}

class _AppSettingsLanguageScreenState extends State<AppSettingsLanguageScreen> {
  bool _initial = true;
  late String _lang = '';
  late AppSettingsProvider _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = Provider.of<AppSettingsProvider>(context);
      _lang =
          _settings.selectedLang ?? AppLocalizations.instance.locale.toString();

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void saveLang(String lang) async {
    await _settings.setSelectedLang(lang);
    await AppLocalizations.delegate.load(Locale(lang));

    setState(() {
      _lang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initial == true) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LanguageSelectorScreen(
      saveLang: saveLang,
      initialLang: _lang,
    );
  }
}
