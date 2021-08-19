import 'package:flutter/material.dart';
import 'package:peercoin/providers/appsettings.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/price_ticker.dart';
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

  List<Widget> renderCurrencies() {
    if (_settings.exchangeRates.isNotEmpty &&
        _settings.selectedCurrency.isNotEmpty) {
      //copy data
      final currencyData = _settings.exchangeRates.keys.toList();
      currencyData.insert(0, 'USD'); //add USD
      currencyData.remove('PPC'); //don't show PPC

      return currencyData.map((currency) {
        return InkWell(
          onTap: () => _settings.setSelectedCurrency(currency),
          child: ListTile(
              title: Text(
                AppLocalizations.instance.translate('currency_$currency'),
              ),
              leading: Radio(
                value: currency,
                groupValue: _settings.selectedCurrency,
                onChanged: (dynamic _) =>
                    _settings.setSelectedCurrency(currency),
              ),
              trailing: Text(
                PriceTicker.currencySymbols[currency] ?? '',
                style: TextStyle(fontWeight: FontWeight.w500),
              )),
        );
      }).toList();
    }
    //TODO maybe show current exchange rate?
    return [Container()];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(children: renderCurrencies()),
        renderButton(),
      ],
    );
  }
  //TODO show settings saved snack bar
  //TODO show data protection alert on enabling the price feed
  //TODO toggle fetch when enabled for first time / exchangeRates is empty
}
