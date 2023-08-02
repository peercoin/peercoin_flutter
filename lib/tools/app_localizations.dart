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

  static const Map<String, (Locale, String)> availableLocales = {
    'en': (Locale('en'), 'English'),
    'af': (Locale('af'), 'Afrikaans'),
    'ar': (Locale('ar'), '(al arabiya) العربية'),
    'bn': (Locale('bn'), 'বাংলা (baɛṅlā)'),
    'id': (Locale('id'), 'Bahasa Indonesia'),
    'my': (Locale('my'), 'မြန်မာဘာသာ (mranma bhasa)'),
    'da': (Locale('da'), 'Dansk'),
    'de': (Locale('de'), 'Deutsch'),
    'es': (Locale('es'), 'Español'),
    'fa': (Locale('fa'), '(fārsī) فارسى'),
    'fil': (Locale('fil'), 'Wikang Filipino'),
    'fr': (Locale('fr'), 'Français'),
    // 'ha': (Locale('ha'), '(ḥawsa) حَوْسَ'), presently not supported by GlobalMaterialLocalizations / https://api.flutter.dev/flutter/flutter_localizations/kMaterialSupportedLanguages.html
    'hi': (Locale('hi'), 'हिन्दी (hindī)'),
    'hr': (Locale('hr'), 'Hrvatski'),
    'ka': (Locale('ka'), 'ქართული (k’art’uli)'),
    'it': (Locale('it'), 'Italiano'),
    'ja': (Locale('ja'), '日本語 (nihongo)'),
    'sw': (Locale('sw'), 'Kiswahili'),
    'ko': (Locale('ko'), '한국어 [韓國語] (han-guk-eo)'),
    'lt': (Locale('lt'), 'Lietuvių kalba'),
    'hu': (Locale('hu'), 'Magyar'),
    'nl': (Locale('nl'), 'Nederlands'),
    'nb': (Locale('nb'), 'Norsk Bokmål'),
    'or': (Locale('or'), 'ଓଡ଼ିଆ (ōṛiā)'),
    'pl': (Locale('pl'), 'Polski'),
    'pt': (Locale('pt'), 'Português'),
    'ps': (Locale('ps'), '(paṣhto) پښتو'),
    'pa': (Locale('pa'), 'ਪੰਜਾਬੀ'),
    'ro': (Locale('ro'), 'Română'),
    'ru': (Locale('ru'), 'Русский'),
    'sq': (Locale('sq'), 'Shqipja'),
    'sv': (Locale('sv'), 'Svenska'),
    'th': (Locale('th'), 'ภาษาไทย (paasaa-tai)'),
    'tl': (Locale('tl'), 'Wikang Tagalog'),
    'tr': (Locale('tr'), 'Türkçe'),
    'uk': (Locale('uk'), 'Українська (Ukrajins’ka)'),
    'ur': (Locale('ur'), '(urdū) اردو'),
    'vi': (Locale('vi'), 'Tiếng Việt'),
    'zh': (Locale('zh'), '中文 (Zhōngwén)'),
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
