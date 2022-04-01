import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:peercoin/providers/app_settings.dart';

import 'logger_wrapper.dart';

class PriceTicker {
  static Future<Map<String, dynamic>> getDataFromTicker() async {
    final client = RetryClient(http.Client());
    var url = Uri.parse('https://peercoinexplorer.net/price-ticker');
    try {
      var response = await client.read(url);
      final Map<String, dynamic> data = json.decode(response);
      return data;
    } catch (err) {
      LoggerWrapper.logError(
        'PriceTicker',
        'getDataFromTicker',
        err.toString(),
      );
      rethrow;
    } finally {
      client.close();
    }
  }

  static Map currencySymbols = {
    'ARS': '\$',
    'AUD': 'A\$',
    'BDT': '৳',
    'CNY': '¥',
    'DKK': 'Kr.',
    'BRL': 'R\$',
    'EUR': '€',
    'GBP': '£',
    'HRK': 'kn',
    'IDR': 'Rp',
    'INR': '₹',
    'IRR': '﷼',
    'JPY': '¥',
    'KES': 'KSh',
    'KRW': '₩',
    'NOK': 'kr',
    'PHP': '₱',
    'PKR': '₨',
    'PLN': 'zł',
    'USD': '\$',
    'RON': 'L',
    'RUB': '₽',
    'SEK': 'kr',
    'THB': '฿',
    'TRY': '₺',
    'TZS': 'TSh',
    'UAH': '₴',
    'UGX': 'USh',
    'VND': '₫'
  };

  static double renderPrice(
      double amount, String currencySymbol, String coinLetterCode, Map prices) {
    if (prices.isEmpty) {
      return 0.0;
    }
    if (currencySymbol != 'USD') {
      return prices[currencySymbol] * amount * prices[coinLetterCode];
    }
    return amount * prices[coinLetterCode];
  }

  static void checkUpdate(AppSettings _settings) async {
    LoggerWrapper.logInfo(
        'PriceTicker', 'checkUpdate', 'checking price update');
    //check if last update was longer than an hour ago
    final oneHourAgo =
        (DateTime.now()).subtract(Duration(minutes: Duration.minutesPerHour));
    if (_settings.latestTickerUpdate.isBefore(oneHourAgo)) {
      LoggerWrapper.logInfo(
        'PriceTicker',
        'checkUpdate',
        'last update older than 1 hour (${_settings.latestTickerUpdate})',
      );
      //time to update
      //get data
      final data = await getDataFromTicker();

      //check if data still contains selectedCurrency
      if (!data.containsKey(_settings.selectedCurrency)) {
        _settings.setSelectedCurrency('USD'); //fallback to USD
      }

      if (mapEquals(data, _settings.exchangeRates) == false) {
        //stored exchange rates need update
        final valuesValid = data.values.every(
          (element) =>
              element.runtimeType == double || element.runtimeType == int,
        );
        if (valuesValid) {
          //data valid
          LoggerWrapper.logInfo(
            'PriceTicker',
            'checkUpdate',
            'price data updated $data',
          );
          _settings.setExchangeRates(data);
        } else {
          LoggerWrapper.logError(
            'PriceTicker',
            'checkUpdate',
            'parser data not valid',
          );
        }
      }

      //update lastTickerUpdate
      _settings.setLatestTickerUpdate(DateTime.now());
    } else {
      LoggerWrapper.logInfo(
        'PriceTicker',
        'checkUpdate',
        'last update happened within the hour. ${_settings.latestTickerUpdate}',
      );
    }
  }
}
