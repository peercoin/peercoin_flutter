import 'package:flutter/material.dart';
class MyTheme{
  static MaterialColor peercoinGreen = MaterialColor(
    _peercoinGreenValue,
    <int, Color>{
      50: Color(0xff3cb054),
      100: Color(0xff3cb054),
      200: Color(0xff3cb054),
      300: Color(0xff3cb054),
      400: Color(0xff3cb054),
      500: Color(0xff3cb054),
      600: Color(0xff3cb054),
      700: Color(0xff3cb054),
      800: Color(0xff3cb054),
      900: Color(0xff3cb054),
    },
  );
  static int _peercoinGreenValue = 0xff3cb054;


  static Map<ThemeMode, ThemeData> appThemes = {
    ThemeMode.light: ThemeData(
      primaryColor: peercoinGreen,
      accentColor: Colors.grey,
      errorColor: Colors.red,
      primarySwatch: peercoinGreen,
      textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(primary: Colors.white),
    ),
  ),
    ThemeMode.dark: ThemeData.dark().copyWith(
      primaryColor: Color(0xff46662B),
      scaffoldBackgroundColor: DarkThemeColors.background,
      accentColor: DarkThemeColors.primaryAccent,
      errorColor: Color(0xffAB0C3D),
    )
  };

  static ThemeData getTheme(ThemeMode mode){
    ThemeData x = appThemes[mode];
   // x.primarySwatch: peercoinGreen;
    return x;
  }
}


//appThemes[ThemeMode.light].

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