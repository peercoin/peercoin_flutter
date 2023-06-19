import 'package:flutter/material.dart';
import 'package:peercoin/screens/settings/settings_helpers.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';

import '../../tools/app_localizations.dart';
import '../../widgets/service_container.dart';

class AppSettingsAppThemeScreen extends StatefulWidget {
  const AppSettingsAppThemeScreen({super.key});

  @override
  State<AppSettingsAppThemeScreen> createState() =>
      _AppSettingsAppThemeScreenState();
}

class _AppSettingsAppThemeScreenState extends State<AppSettingsAppThemeScreen> {
  bool _initial = true;
  String _selectedTheme = '';
  final Map _availableThemes = {
    'system': ThemeMode.system,
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
  };

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      final themeModeHandler = ThemeModeHandler.of(context)!;

      _selectedTheme =
          themeModeHandler.themeMode.toString().replaceFirst('ThemeMode.', '');

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void saveTheme(String label, ThemeMode theme) async {
    await ThemeModeHandler.of(context)!.saveThemeMode(theme);
    setState(() {
      _selectedTheme = label;
    });
    //show notification
    // ignore: use_build_context_synchronously
    saveSnack(context);
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('app_settings_theme'),
        ),
      ),
      body: SingleChildScrollView(
        child: Align(
          child: PeerContainer(
            noSpacers: true,
            child: Column(
              children: _availableThemes.keys.map((theme) {
                return InkWell(
                  onTap: () => saveTheme(theme, _availableThemes[theme]),
                  child: ListTile(
                    title: Text(
                      AppLocalizations.instance
                          .translate('app_settings_theme_$theme'),
                    ),
                    leading: Radio(
                      value: theme,
                      groupValue: _selectedTheme,
                      onChanged: (dynamic _) =>
                          saveTheme(theme, _availableThemes[theme]),
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
