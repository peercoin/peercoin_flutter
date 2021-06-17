import 'package:flutter/material.dart';

class MyTheme {

  static Map<ThemeMode, ThemeData> appThemes = {
    ThemeMode.light: ThemeData(

      accentColor: LightColors.darkBlue,
      backgroundColor: LightColors.white,
      buttonColor: LightColors.darkBlue,
      cardColor: LightColors.white,
      dialogBackgroundColor: LightColors.white,
      disabledColor: LightColors.gray,
      errorColor: LightColors.red,
      focusColor: LightColors.green,
      primaryColor: LightColors.green,
      primarySwatch: materialColor(LightColors.darkBlue),
      shadowColor: LightColors.lightBlue,
      unselectedWidgetColor: LightColors.lightGreen,

      cardTheme: CardTheme(
        elevation: 2,
        color: LightColors.white,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: LightColors.darkBlue,
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
  static Color get darkBlue => const Color(0xFF2C4251);
  static Color get lightBlue => const Color(0xFFA6CFD5);
  static Color get white => const Color(0xFFFFFFFC);
  static Color get gray => const Color(0xFF97A7B3);
  static Color get black => const Color(0xFF000000);
  static Color get red => const Color(0xFFF8333C);
  static Color get yellow => const Color(0xFFFFBF46);
}

abstract class DarkColors {
  static Color get background => const Color(0xFF10041A);
  static Color get primaryContent => const Color(0xFFE1E1E1);
  static Color get primaryAccent => const Color(0xFFC7482A);
}
