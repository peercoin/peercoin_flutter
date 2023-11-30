import 'package:flutter/material.dart';

class MyTheme {
  static Map<ThemeMode, ThemeData> appThemes = {
    ThemeMode.light: ThemeData(
      cardColor: LightColors.white,
      dialogBackgroundColor: LightColors.white,
      disabledColor: LightColors.lightGreen,
      dividerColor: LightColors.darkGreen,
      focusColor: LightColors.green,
      hintColor: LightColors.grey,
      primaryColor: LightColors.green,
      shadowColor: LightColors.lightGreen,
      unselectedWidgetColor: LightColors.grey,
      textTheme: TextTheme(
        labelLarge: TextStyle(
          letterSpacing: 1.4,
          fontSize: 16,
          color: DarkColors.white,
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        color: LightColors.green,
        foregroundColor: LightColors.white,
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
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LightColors.green,
        contentTextStyle: TextStyle(color: LightColors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: LightColors.green,
          backgroundColor: LightColors.green,
          textStyle: TextStyle(
            color: LightColors.white,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LightColors.green,
        ),
      ),
      colorScheme: ColorScheme(
        primary: LightColors.green,
        primaryContainer: LightColors.darkGreen,
        secondary: LightColors.grey,
        secondaryContainer: LightColors.lightGrey,
        surface: LightColors.white,
        background: LightColors.grey,
        error: LightColors.red,
        onPrimary: LightColors.white,
        onSecondary: LightColors.blackGreen,
        onSurface: LightColors.black,
        onBackground: LightColors.green,
        onError: LightColors.red,
        brightness: Brightness.light,
      )
          .copyWith(background: LightColors.white)
          .copyWith(error: LightColors.red),
      bottomAppBarTheme: const BottomAppBarTheme(color: Color(0x003cb054)),
    ),
    ThemeMode.dark: ThemeData.dark().copyWith(
      cardColor: DarkColors.green,
      dialogBackgroundColor: DarkColors.green,
      disabledColor: DarkColors.darkBlue,
      dividerColor: DarkColors.lightGreen,
      focusColor: DarkColors.black,
      hintColor: DarkColors.white,
      primaryColor: DarkColors.black,
      iconTheme: IconThemeData(color: DarkColors.white),
      scaffoldBackgroundColor: DarkColors.green,
      shadowColor: DarkColors.darkBlue,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DarkColors.darkBlue,
        contentTextStyle: TextStyle(color: DarkColors.white),
      ),
      sliderTheme: SliderThemeData(valueIndicatorColor: DarkColors.darkBlue),
      unselectedWidgetColor: DarkColors.white,
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(DarkColors.white),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: DarkColors.white),
        headlineSmall: TextStyle(color: DarkColors.white),
        headlineMedium: TextStyle(color: DarkColors.white),
        displaySmall: TextStyle(color: DarkColors.white),
        displayMedium: TextStyle(color: DarkColors.white),
        displayLarge: TextStyle(color: DarkColors.white),
        titleMedium: TextStyle(color: DarkColors.white),
        titleSmall: TextStyle(color: DarkColors.white),
        bodyLarge: TextStyle(color: DarkColors.white),
        bodyMedium: TextStyle(color: DarkColors.white),
        labelLarge: TextStyle(
          letterSpacing: 1.4,
          fontSize: 16,
          color: DarkColors.white,
        ),
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
          foregroundColor: DarkColors.white,
          backgroundColor: DarkColors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DarkColors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: DarkColors.white),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: DarkColors.white),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: DarkColors.white,
      ),
      colorScheme: ColorScheme(
        primary: DarkColors.green,
        primaryContainer: DarkColors.white,
        secondary: DarkColors.white,
        secondaryContainer: DarkColors.grey,
        surface: DarkColors.black,
        background: DarkColors.green,
        error: DarkColors.red,
        onPrimary: DarkColors.green,
        onSecondary: DarkColors.green,
        onSurface: DarkColors.white,
        onBackground: DarkColors.green,
        onError: DarkColors.red,
        brightness: Brightness.dark,
      ).copyWith(background: DarkColors.green).copyWith(error: DarkColors.red),
      bottomAppBarTheme: const BottomAppBarTheme(color: Color(0x000D1821)),
    ),
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
  static Color get lightGrey => const Color(0x55717C89);
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
