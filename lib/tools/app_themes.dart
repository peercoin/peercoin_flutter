import 'package:flutter/material.dart';

final Map<ThemeMode, ThemeData> appThemes = {
  ThemeMode.light: ThemeData.light().copyWith(
    primaryColor: Color(0xff3cb054),
    scaffoldBackgroundColor: LightThemeColors.background,
    accentColor: LightThemeColors.primaryAccent,
    errorColor: Colors.red,
  ),
  ThemeMode.dark: ThemeData.dark().copyWith(
    primaryColor: Color(0xff46662B),
    scaffoldBackgroundColor: DarkThemeColors.background,
    accentColor: DarkThemeColors.primaryAccent,
    errorColor: Color(0xffAB0C3D),
  )
};

abstract class LightThemeColors {
  static Color get background => const Color(0xFFFFFFFF);
  static Color get primaryContent => const Color(0xFF000000);
  static Color get primaryAccent => Colors.grey;
}

abstract class DarkThemeColors {
  static Color get background => const Color(0xFF10041A);
  static Color get primaryContent => const Color(0xFFE1E1E1);
  static Color get primaryAccent => const Color(0xFFC7482A);
}
/*
class ThemedColor {
  final Color light;
  final Color dark;

  const ThemedColor({
    @required this.light,
    @required this.dark,
  })  : assert(light != null),
        assert(dark != null);

  Color getColor(BuildContext context) {
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        return light;
      case Brightness.dark:
        return dark;
    }
    throw UnsupportedError('${Theme.of(context).brightness} is not supported');
  }
}*/
/*
abstract class AppColors {
  static Color background(BuildContext context) => ThemedColor(
    light: LightThemeColors.background,
    dark: DarkThemeColors.background,
  ).getColor(context);

  static Color primaryContent(BuildContext context) => ThemedColor(
    light: LightThemeColors.primaryContent,
    dark: DarkThemeColors.primaryContent,
  ).getColor(context);

  static Color primaryAccent(BuildContext context) => ThemedColor(
    light: LightThemeColors.primaryAccent,
    dark: DarkThemeColors.primaryAccent,
  ).getColor(context);
}
*/