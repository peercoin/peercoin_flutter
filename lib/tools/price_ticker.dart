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

  static void checkUpdate(AppSettings _settings) async {
    //check if last update was longer than an hour ago
    final oneHourAgo =
        (DateTime.now()).subtract(Duration(minutes: Duration.minutesPerHour));
    if (_settings.latestTickerUpdate.isBefore(oneHourAgo)) {
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

  //TODO app settings screen maps the currency dynamically - store currency symbols
  //TODO global listener AppLifecycleState.resumed to not only sync on app start... or just put a timer every hour?
}
