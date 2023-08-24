import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import '../providers/app_settings_provider.dart';
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
    'VND': '₫',
    'AED': 'د.إ',
    'ALL': 'Lek',
    'AMD': '֏',
    'AOA': 'Kz',
    'AZN': '₼',
    'BAM': 'KM',
    'BGN': 'лв',
    'BHD': 'ب.د',
    'BIF': 'FBu',
    'BND': '\$',
    'BOB': 'Bs.',
    'BSD': '\$',
    'BTN': 'Nu.',
    'BWP': 'P',
    'BYN': 'Br',
    'CAD': '\$',
    'CDF': 'FC',
    'CHF': 'Fr.',
    'CLP': '\$',
    'COP': '\$',
    'CRC': '₡',
    'CVE': 'Esc',
    'CZK': 'Kč',
    'DOP': 'RD\$',
    'EGP': 'ج.م',
    'GEL': '₾',
    'GMD': 'D',
    'GNF': 'FG',
    'GTQ': 'Q',
    'GYD': '\$',
    'HKD': '\$',
    'HNL': 'L',
    'HUF': 'Ft',
    'ILS': '₪',
    'IQD': 'ع.د',
    'ISK': 'kr',
    'JMD': '\$',
    'JOD': 'د.ا',
    'KGS': 'лв',
    'KMF': 'CF',
    'KWD': 'د.ك',
    'KZT': '₸',
    'LAK': '₭',
    'LBP': 'ل.ل',
    'LKR': '₨',
    'LRD': '\$',
    'LSL': 'L',
    'LYD': 'ل.د',
    'MAD': 'د.م.',
    'MDL': 'L',
    'MGA': 'Ar',
    'MKD': 'ден',
    'MNT': '₮',
    'MOP': 'P',
    'MUR': '₨',
    'MVR': 'ރ.',
    'MWK': 'MK',
    'MYR': 'RM',
    'MXN': '\$',
    'MZN': 'MT',
    'NAD': '\$',
    'NGN': '₦',
    'NZD': '\$',
    'OMR': 'ر.ع.',
    'PEN': 'S/',
    'PYG': '₲',
    'QAR': 'ر.ق',
    'RSD': 'дин',
    'RWF': 'FRw',
    'SAR': 'ر.س',
    'SCR': '₨',
    'SDG': 'ج.س.',
    'SGD': '\$',
    'SLL': 'Le',
    'STD': 'Db',
    'SZL': 'L',
    'TJS': 'SM',
    'TND': 'د.ت',
    'TTD': '\$',
    'TWD': 'NT\$',
    'UYU': '\$U',
    'XAF': 'FCFA',
    'XOF': 'CFA',
    'XPF': '₣',
    'ZAR': 'R',
    'ZMK': 'ZK',
    'AFN': '؋',
    'ANG': 'ƒ',
    'AWG': 'ƒ',
    'BBD': '\$',
    'BMD': '\$',
    'BZD': 'BZ\$',
    'CUP': '\$',
    'DJF': 'Fdj',
    'DZD': 'د.ج',
    'ERN': 'Nfk',
    'ETB': 'ብር',
    'GHS': '₵',
    'GIP': '£',
    'HTG': 'G',
    'KHR': '៛',
    'KPW': '₩',
    'KYD': '\$',
    'MMK': 'K',
    'MRO': 'UM',
    'NIO': 'C\$',
    'NPR': '₨',
    'PAB': 'B/.',
    'SBD': '\$',
    'SHP': '£',
    'SOS': 'S',
    'SRD': '\$',
    'SSP': '£',
    'SVC': '\$',
    'SYP': '£',
    'TMT': 'T',
    'TOP': 'T\$',
    'UZS': 'лв',
    'VEF': 'Bs',
    'VUV': 'Vt',
    'WST': 'WS\$',
    'XCD': '\$',
  };

  static double renderPrice(
    double amount,
    String currencySymbol,
    String coinLetterCode,
    Map prices,
  ) {
    if (prices.isEmpty || prices.containsKey(coinLetterCode) == false) {
      return 0.0;
    }
    if (currencySymbol != 'USD') {
      return prices[currencySymbol] * amount * prices[coinLetterCode];
    }
    return amount * prices[coinLetterCode];
  }

  static void checkUpdate(AppSettingsProvider settings) async {
    LoggerWrapper.logInfo(
      'PriceTicker',
      'checkUpdate',
      'checking price update',
    );
    //check if last update was longer than an hour ago
    final oneHourAgo = (DateTime.now())
        .subtract(const Duration(minutes: Duration.minutesPerHour));
    if (settings.latestTickerUpdate.isBefore(oneHourAgo)) {
      LoggerWrapper.logInfo(
        'PriceTicker',
        'checkUpdate',
        'last update older than 1 hour (${settings.latestTickerUpdate})',
      );
      //time to update
      //get data
      final data = await getDataFromTicker();

      //check if data still contains selectedCurrency
      if (!data.containsKey(settings.selectedCurrency)) {
        settings.setSelectedCurrency('USD'); //fallback to USD
      }

      if (mapEquals(data, settings.exchangeRates) == false) {
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
          settings.setExchangeRates(data);
        } else {
          LoggerWrapper.logError(
            'PriceTicker',
            'checkUpdate',
            'parser data not valid',
          );
        }
      }

      //update lastTickerUpdate
      settings.setLatestTickerUpdate(DateTime.now());
    } else {
      LoggerWrapper.logInfo(
        'PriceTicker',
        'checkUpdate',
        'last update happened within the hour. ${settings.latestTickerUpdate}',
      );
    }
  }
}
