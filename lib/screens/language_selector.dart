import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:flutter/material.dart';

import '../../tools/app_localizations.dart';
import '../../widgets/service_container.dart';

class LanguageSelectorScreen extends StatefulWidget {
  final Function saveLang;
  final String initialLang;
  const LanguageSelectorScreen({
    super.key,
    required this.saveLang,
    required this.initialLang,
  });

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  bool _initial = true;
  String _searchString = '';
  List<String> _filteredLanguages = [];

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      updateFilteredList();
      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
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

  void _saveLang(String savedLang) async {
    await widget.saveLang(savedLang);

    if (mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
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

    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        closeOnSubmit: true,
        clearOnClose: true,
        fieldHintText:
            AppLocalizations.instance.translate('app_settings_language_search'),
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
                  onTap: () => _saveLang(lang),
                  child: ListTile(
                    title: Text(langTitle),
                    subtitle: Text('${locale.languageCode} $countryCode'),
                    key: Key(lang),
                    leading: Radio(
                      value: lang,
                      groupValue: widget.initialLang,
                      onChanged: (_) => _saveLang(lang),
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
