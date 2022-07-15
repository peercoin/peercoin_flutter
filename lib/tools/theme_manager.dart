import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_mode_handler/theme_mode_manager_interface.dart';

class ThemeManager implements IThemeModeManager {
  ThemeManager();

  @override
  Future<String> loadThemeMode() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();

    //compute theme setting
    var themeString = prefs.getString('theme_mode') ?? 'ThemeMode.system';
    return themeString;
  }

  @override
  Future<bool> saveThemeMode(String value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', value);
    return true;
  }
}
