import 'package:flutter/material.dart';
import 'package:peercoin/screens/language_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tools/app_localizations.dart';

class SetupLanguageScreen extends StatefulWidget {
  const SetupLanguageScreen({super.key});

  @override
  State<SetupLanguageScreen> createState() => _SetupLanguageScreenState();
}

class _SetupLanguageScreenState extends State<SetupLanguageScreen> {
  String _lang = '';
  bool _initial = true;
  late SharedPreferences prefs;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      prefs = await SharedPreferences.getInstance();
      _lang = prefs.getString('language_code') ??
          AppLocalizations.instance.locale.toString();
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void saveLang(String lang) async {
    await prefs.setString('language_code', lang);
    await AppLocalizations.delegate.load(Locale(lang));
    setState(() {
      _lang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LanguageSelectorScreen(
      saveLang: saveLang,
      selectedLang: _lang,
    );
  }
}
