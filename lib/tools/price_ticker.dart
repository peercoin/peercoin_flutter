import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:peercoin/providers/appsettings.dart';

class PriceTicker {
  static Future<Map<String, dynamic>> getDataFromTicker() async {
    final client = RetryClient(http.Client());
    var url = Uri.parse('https://peercoinexplorer.net/price-ticker');
    try {
      var response = await client.read(url);
      final Map<String, dynamic> data = json.decode(response);
      return data;
    } catch (err) {
      rethrow;
    } finally {
      client.close();
    }
  }

  static Map currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'ARS': '\$',
    'BRL': 'R\$',
    'CNY': '¥',
    'GBP': '£',
    'HRK': 'kn',
    'INR': '₹',
    'PLN': 'zł',
    'RON': 'L',
    'RUB': '₽',
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
    log('checking price update');
    //check if last update was longer than an hour ago
    final oneHourAgo =
        (DateTime.now()).subtract(Duration(minutes: Duration.minutesPerHour));
    if (_settings.latestTickerUpdate.isBefore(oneHourAgo)) {
      log('last update older than 1 hour (${_settings.latestTickerUpdate})');
      //time to update
      //get data
      final data = await getDataFromTicker();
      if (mapEquals(data, _settings.exchangeRates) == false) {
        //stored exchange rates need update
        final valuesValid =
            data.values.every((element) => element.runtimeType == double);
        if (valuesValid) {
          //data valid
          log('price data updated $data');
          _settings.setExchangeRates(data);
        } else {
          throw ('parser data not valid');
        }
      }
      //update lastTickerUpdate
      _settings.setLatestTickerUpdate(DateTime.now());
    }
  }
}
