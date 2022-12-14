import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logger_wrapper.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale fallbackLocale = const Locale('en');

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static late AppLocalizations instance;

  AppLocalizations._init(this.locale) {
    instance = this;
  }

  static const Map<String, String> availableLocales = {
    'en': 'English',
    'ar': '(al arabiya) العربية',
    'bn': 'বাংলা (baɛṅlā)',
    'id': 'Bahasa Indonesia',
    'da': 'Dansk',
    'de': 'Deutsch',
    'es': 'Español',
    'fa': '(fārsī) فارسى',
    'fil': 'Wikang Filipino',
    'fr': 'Français',
    // 'ha': '(ḥawsa) حَوْسَ', presently not supported by GlobalMaterialLocalizations / https://api.flutter.dev/flutter/flutter_localizations/kMaterialSupportedLanguages.html
    'hi': 'हिन्दी (hindī)',
    'hr': 'Hrvatski',
    'it': 'Italiano',
    'ja': '日本語 (nihongo)',
    'sw': 'Kiswahili',
    'ko': '한국어 [韓國語] (han-guk-eo)',
    'nl': 'Nederlands',
    'nb': 'Norsk Bokmål',
    'pl': 'Polski',
    'pt': 'Português',
    'ro': 'Română',
    'ru': 'Русский',
    'sv': 'Svenska',
    'th': 'ภาษาไทย (paasaa-tai)',
    'tr': 'Türkçe',
    'uk': 'Українська (Ukrajins’ka)',
    'ur': '(urdū) اردو',
    'vi': 'Tiếng Việt',
    'zh': '中文 (Zhōngwén)'
  };

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Locale? locale;
  late Map<String, String> _localizedStrings;
  late Map<String, String> _fallbackLocalizedStrings;

  Future<void> load() async {
    _localizedStrings = await _loadLocalizedStrings(locale!);
    _fallbackLocalizedStrings = {};

    if (locale != fallbackLocale) {
      _fallbackLocalizedStrings = await _loadLocalizedStrings(fallbackLocale);
    }
  }

  Future<String> _getFilePath(Locale localeToBeLoaded) async {
    switch (localeToBeLoaded.languageCode) {
      case 'bn':
        return 'assets/translations/bn_BD.json';
      case 'nb':
        return 'assets/translations/nb_NO.json';
      default:
        return 'assets/translations/${localeToBeLoaded.languageCode}.json';
    }
  }

  Future<Map<String, String>> _loadLocalizedStrings(
    Locale localeToBeLoaded,
  ) async {
    String jsonString;
    var localizedStrings = <String, String>{};

    try {
      jsonString =
          await rootBundle.loadString(await _getFilePath(localeToBeLoaded));
    } catch (e) {
      LoggerWrapper.logError(
        'AppLocalizations',
        '_loadLocalizedStrings',
        e.toString(),
      );
      return localizedStrings;
    }

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return localizedStrings;
  }

  String translate(String key, [Map<String, String?>? arguments]) {
    var translation = _localizedStrings[key];
    translation = translation ?? _fallbackLocalizedStrings[key];
    translation = translation ?? '';

    if (arguments == null || arguments.isEmpty) {
      return translation;
    }

    arguments.forEach((argumentKey, value) {
      if (value == null) {
        LoggerWrapper.logWarn(
          'AppLocalizations',
          'translate',
          'Value for "$argumentKey" is null in call of translate(\'$key\')',
        );
        value = '';
      }
      translation = translation!.replaceAll('\$$argumentKey', value);
    });

    return translation ?? '';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localizations = AppLocalizations._init(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

//TODO go through setup and check for line breaks for all languages
