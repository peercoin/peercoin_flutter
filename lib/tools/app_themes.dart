import 'package:flutter/material.dart';

class MyTheme {

  static Map<ThemeMode, ThemeData> appThemes = {
    ThemeMode.light: ThemeData(

      accentColor: LightColors.grey,
      backgroundColor: LightColors.white,
      cardColor: LightColors.white,
      dialogBackgroundColor: LightColors.white,
      disabledColor: LightColors.lightGreen,
      errorColor: LightColors.red,
      focusColor: LightColors.green,
      primaryColor: LightColors.green,
      primarySwatch: materialColor(LightColors.grey),
      shadowColor: LightColors.lightGreen,
      unselectedWidgetColor: LightColors.grey,

      cardTheme: CardTheme(
        elevation: 2,
        color: LightColors.white,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        shape: RoundedRectangleBorder( //to set border radius to button
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: LightColors.green,
          onPrimary: LightColors.white,
        ),
      ),
    ),
    ThemeMode.dark: ThemeData.dark().copyWith(
      primaryColor: Color(0xff46662B),
      scaffoldBackgroundColor: DarkColors.background,
      accentColor: DarkColors.primaryAccent,
      errorColor: Color(0xffAB0C3D),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        primary: Color(0xff46662B),
        onPrimary: Colors.white,
      )),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        primary: Color(0xff46662B),
      )),
    )
  };

  static ThemeData getTheme(ThemeMode mode) {
    return appThemes[mode];
  }

  static MaterialColor materialColor(Color color){
    return MaterialColor(
      color.value,
      <int, Color>{
        50: color,
        100: color,
        200: color,
        300: color,
        400: color,
        500: color,
        600: color,
        700: color,
        800: color,
        900: color,
      },
    );
  }
}

abstract class LightColors {
  static Color get green => const Color(0xff3cb054);
  static Color get lightGreen => const Color(0xffB3E5BD);
  static Color get grey => const Color(0xFF717C89);
  static Color get white => const Color(0xFFFDFFFC);
  static Color get black => const Color(0xFF000000);
  static Color get red => const Color(0xFFF8333C);
  static Color get yellow => const Color(0xFFFFBF46);
}

abstract class DarkColors {
  static Color get background => const Color(0xFF10041A);
  static Color get primaryContent => const Color(0xFFE1E1E1);
  static Color get primaryAccent => const Color(0xFFC7482A);
}
