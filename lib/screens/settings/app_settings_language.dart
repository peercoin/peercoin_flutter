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
  late String _lang = '';
  late AppSettings _settings;

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = Provider.of<AppSettings>(context);
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_language'),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: AppLocalizations.availableLocales.keys.map((lang) {
                final (_, langTitle) = AppLocalizations.availableLocales[lang]!;
                return InkWell(
                  onTap: () => saveLang(lang),
                  child: ListTile(
                    title: Text(langTitle),
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
