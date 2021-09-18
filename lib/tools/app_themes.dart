import 'package:flutter/material.dart';

class MyTheme {
  static Map<ThemeMode, ThemeData> appThemes = {
    ThemeMode.light: ThemeData(
      colorScheme: ColorScheme(
        primary: LightColors.green,
        primaryVariant: LightColors.darkGreen,
        secondary: LightColors.grey,
        secondaryVariant: LightColors.grey,
        surface: LightColors.white,
        background: LightColors.grey,
        error: LightColors.red,
        onPrimary: LightColors.white,
        onSecondary: LightColors.blackGreen,
        onSurface: LightColors.green,
        onBackground: LightColors.green,
        onError: LightColors.red,
        brightness: Brightness.light,
      ),
      backgroundColor: LightColors.white,
      bottomAppBarColor: const Color(0x003cb054),
      cardColor: LightColors.white,
      dialogBackgroundColor: LightColors.white,
      disabledColor: LightColors.lightGreen,
      dividerColor: LightColors.darkGreen,
      errorColor: LightColors.red,
      focusColor: LightColors.green,
      hintColor: LightColors.grey,
      primaryColor: LightColors.green,
      primarySwatch: materialColor(LightColors.grey),
      shadowColor: LightColors.lightGreen,
      unselectedWidgetColor: LightColors.grey,
      textTheme: TextTheme(
        button: TextStyle(
            letterSpacing: 1.4, fontSize: 16, color: DarkColors.white),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: LightColors.darkGreen,
        color: LightColors.white,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            primary: LightColors.green,
            onPrimary: LightColors.green,
            textStyle: TextStyle(
              color: LightColors.white,
            )),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        primary: LightColors.green,
      )),
    ),
    ThemeMode.dark: ThemeData.dark().copyWith(
      colorScheme: ColorScheme(
        primary: DarkColors.green,
        primaryVariant: DarkColors.white,
        secondary: DarkColors.white,
        secondaryVariant: DarkColors.grey,
        surface: DarkColors.black,
        background: DarkColors.green,
        error: DarkColors.red,
        onPrimary: DarkColors.green,
        onSecondary: DarkColors.green,
        onSurface: DarkColors.green,
        onBackground: DarkColors.green,
        onError: DarkColors.red,
        brightness: Brightness.dark,
      ),
      backgroundColor: DarkColors.green,
      bottomAppBarColor: const Color(0x000D1821),
      cardColor: DarkColors.green,
      dialogBackgroundColor: DarkColors.green,
      disabledColor: DarkColors.darkBlue,
      dividerColor: DarkColors.lightGreen,
      errorColor: DarkColors.red,
      focusColor: DarkColors.black,
      hintColor: DarkColors.white,
      primaryColor: DarkColors.black,
      scaffoldBackgroundColor: DarkColors.green,
      shadowColor: DarkColors.darkBlue,
      unselectedWidgetColor: DarkColors.grey,
      textTheme: TextTheme(
        headline6: TextStyle(color: DarkColors.white),
        headline5: TextStyle(color: DarkColors.white),
        headline4: TextStyle(color: DarkColors.white),
        headline3: TextStyle(color: DarkColors.white),
        headline2: TextStyle(color: DarkColors.white),
        headline1: TextStyle(color: DarkColors.white),
        subtitle1: TextStyle(color: DarkColors.white),
        subtitle2: TextStyle(color: DarkColors.white),
        bodyText1: TextStyle(color: DarkColors.white),
        bodyText2: TextStyle(color: DarkColors.white),
        button: TextStyle(
            letterSpacing: 1.4, fontSize: 16, color: DarkColors.white),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: DarkColors.green,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: DarkColors.white,
          onPrimary: DarkColors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        primary: DarkColors.black,
      )),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: DarkColors.white),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: DarkColors.white),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: DarkColors.white,
      ),
    )
  };

  static ThemeData getTheme(ThemeMode mode) {
    return appThemes[mode] ?? appThemes[ThemeMode.light]!;
  }

  static MaterialColor materialColor(Color color) {
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
  static Color get black => const Color(0xFF000000);
  static Color get blackGreen => const Color(0xFF31493C);
  static Color get darkGreen => const Color(0xFF2A7A3A);
  static Color get green => const Color(0xff3cb054);
  static Color get lightGreen => const Color(0xffB3E5BD);
  static Color get grey => const Color(0xFF717C89);
  static Color get white => const Color(0xFFFAFAFA);
  static Color get red => const Color(0xFFF8333C);
  static Color get yellow => const Color(0xFFFFBF46);
}

abstract class DarkColors {
  static Color get black => const Color(0xFF0D1821);
  static Color get darkGreen => const Color(0xFF2A7A3A);
  static Color get green => const Color(0xFF2D936C);
  static Color get lightGreen => const Color(0xffB3E5BD);
  static Color get darkBlue => const Color(0xFF234058);
  static Color get grey => const Color(0xFF717C89);
  static Color get white => const Color(0xFFFAFAFA);
  static Color get red => const Color(0xFFA8201A);
}
