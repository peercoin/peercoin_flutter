import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';

class SettingsPriceTicker extends StatelessWidget {
  final AppSettings _settings;

  SettingsPriceTicker(this._settings);

  Widget renderButton() {
    if (_settings.selectedCurrency.isEmpty) {
      return PeerButton(
        text: AppLocalizations.instance
            .translate('app_settings_price_feed_enable_button'),
        action: () => _settings.setSelectedCurrency('USD'),
      );
    }
    return PeerButton(
      text: AppLocalizations.instance
          .translate('app_settings_price_feed_disable_button'),
      action: () => _settings.setSelectedCurrency(''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [renderButton()],
    );
  }
  //TODO show settings saved snack bar
}
