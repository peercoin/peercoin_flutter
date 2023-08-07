import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/service_container.dart';

class AppSettingsLanguageScreen extends StatefulWidget {
  const AppSettingsLanguageScreen({super.key});

  @override
  State<AppSettingsLanguageScreen> createState() =>
      _AppSettingsLanguageScreenState();
}

class _AppSettingsLanguageScreenState extends State<AppSettingsLanguageScreen> {
  bool _initial = true;
  String _searchString = '';
  List<String> _filteredLanguages = [];
  late String _lang = '';
  late AppSettings _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = Provider.of<AppSettings>(context);
      updateFilteredList();
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void saveLang(String lang) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await _settings.setSelectedLang(lang);
    await AppLocalizations.delegate.load(Locale(lang));

    //show notification
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate('app_settings_saved_snack'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void updateFilteredList() {
    _filteredLanguages = AppLocalizations.availableLocales.keys.where((lang) {
      return lang.toLowerCase().contains(
                _searchString.toLowerCase(),
              ) ||
          AppLocalizations.availableLocales[lang]!.$2.toLowerCase().contains(
                _searchString.toLowerCase(),
              );
    }).toList();
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

    _lang =
        _settings.selectedLang ?? AppLocalizations.instance.locale.toString();

    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        closeOnSubmit: true,
        clearOnClose: true,
        onChanged: (text) {
          setState(() {
            _searchString = text;
          });
          updateFilteredList();
        },
        onCleared: () => setState(() {
          _searchString = '';
        }),
        appBarBuilder: (context) {
          return AppBar(
            title: Text(
              AppLocalizations.instance.translate('app_settings_language'),
            ),
            actions: const [
              AppBarSearchButton(),
            ],
          );
        },
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: _filteredLanguages.map((lang) {
                final (locale, langTitle) =
                    AppLocalizations.availableLocales[lang]!;
                final countryCode = locale.countryCode ?? '';
                return InkWell(
                  onTap: () => saveLang(lang),
                  child: ListTile(
                    title: Text(langTitle),
                    subtitle: Text('${locale.languageCode} $countryCode'),
                    key: Key(lang),
                    leading: Radio(
                      value: lang,
                      groupValue: _lang,
                      onChanged: (dynamic _) => saveLang(lang),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
