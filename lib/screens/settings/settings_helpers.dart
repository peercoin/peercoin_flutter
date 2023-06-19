import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';

const Map<String, String> availableSettings = {
  'app_settings_language': Routes.appSettingsLanguage,
  if (!kIsWeb) 'app_settings_default_wallet': Routes.appSettingsDefaultWallet,
  if (!kIsWeb) 'app_settings_notifications': Routes.appSettingsNotifications
};

void saveSnack(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        AppLocalizations.instance.translate(
          'app_settings_saved_snack',
        ),
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
