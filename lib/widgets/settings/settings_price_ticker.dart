import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/app_settings.dart';
import '../../tools/app_localizations.dart';
import '../../tools/price_ticker.dart';
import '../buttons.dart';

class SettingsPriceTicker extends StatefulWidget {
  final AppSettings _settings;
  final Function _saveSnack;

  const SettingsPriceTicker(this._settings, this._saveSnack, {Key? key})
      : super(key: key);

  @override
  State<SettingsPriceTicker> createState() => _SettingsPriceTickerState();
}

class _SettingsPriceTickerState extends State<SettingsPriceTicker> {
  late String _formattedTime;

  @override
  void didChangeDependencies() {
    _formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(widget._settings.latestTickerUpdate);
    super.didChangeDependencies();
  }

  void enableFeed(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('setup_continue_alert_title'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.instance
                .translate('app_settings_price_alert_content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () {
                widget._settings.setSelectedCurrency('USD');
                PriceTicker.checkUpdate(widget._settings);
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget renderButton(BuildContext ctx) {
    if (widget._settings.selectedCurrency.isEmpty) {
      return PeerButton(
        text: AppLocalizations.instance
            .translate('app_settings_price_feed_enable_button'),
        action: () => enableFeed(ctx),
      );
    }
    return PeerButton(
      text: AppLocalizations.instance
          .translate('app_settings_price_feed_disable_button'),
      action: () {
        widget._settings.setSelectedCurrency('');
      },
    );
  }

  void saveCurrency(BuildContext ctx, String newCurrency) {
    widget._settings.setSelectedCurrency(newCurrency);
    widget._saveSnack(ctx);
  }

  List<Widget> renderCurrencies(BuildContext ctx) {
    if (widget._settings.exchangeRates.isNotEmpty &&
        widget._settings.selectedCurrency.isNotEmpty) {
      //copy data
      final currencyData = widget._settings.exchangeRates.keys.toList();
      currencyData.insert(0, 'USD'); //add USD
      currencyData.remove('PPC'); //don't show PPC

      return currencyData.map((currency) {
        return InkWell(
          onTap: () => saveCurrency(ctx, currency),
          child: ListTile(
            title: Text(
              AppLocalizations.instance.translate('currency_$currency'),
            ),
            subtitle: Text(
              '1 PPC = ${PriceTicker.renderPrice(1, currency, "PPC", widget._settings.exchangeRates).toStringAsFixed(6)} $currency',
            ),
            leading: Radio(
              value: currency,
              groupValue: widget._settings.selectedCurrency,
              onChanged: (dynamic _) => saveCurrency(ctx, currency),
            ),
            trailing: Text(
              PriceTicker.currencySymbols[currency] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        );
      }).toList();
    }
    return [Container()];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget._settings.selectedCurrency.isNotEmpty
            ? Text(
                AppLocalizations.instance.translate(
                  'setup_price_feed_last_update',
                  {'timestamp': _formattedTime},
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
            : Container(),
        Column(
          children: renderCurrencies(context),
        ),
        renderButton(context),
      ],
    );
  }
}
