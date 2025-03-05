import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';

final Map<String, String> _availableSettings = {
  'app_settings_language': Routes.appSettingsLanguage,
  'app_settings_default_wallet': Routes.appSettingsDefaultWallet,
  'app_settings_notifications': Routes.appSettingsNotifications,
  'app_settings_wallet_order': Routes.appSettingsWalletOrder,
  'wallet_scan': Routes.appSettingsWalletScanner,
  'app_settings_auth_header': Routes.appSettingsAuthentication,
  'app_settings_price_feed': Routes.appSettingsPriceFeed,
  'app_settings_theme': Routes.appSettingsAppTheme,
  'server_settings_title': Routes.serverSettingsHome,
  'app_settings_experimental_features': Routes.appSettingsExperimentalFeatures,
};

get availableSettings {
  if (kIsWeb == true) {
    //these settings are not available on web
    _availableSettings.remove('app_settings_default_wallet');
    _availableSettings.remove('app_settings_notifications');
  }

  return _availableSettings;
}

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
