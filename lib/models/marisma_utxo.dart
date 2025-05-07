import 'dart:convert';

import 'package:peercoin/models/available_coins.dart';

class UtxoFromMarisma {
  final String txid;
  final int vout;
  final int amount;

  UtxoFromMarisma({
    required this.txid,
    required this.vout,
    required this.amount,
  });

  factory UtxoFromMarisma.fromJson(
      Map<String, dynamic> json, String identifier) {
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: identifier,
    );
    // Convert value from double to int (satoshis)
    // The API provides value in full coins
    final double valueInCoins = json['value'] as double;
    final int valueInSatoshis = (valueInCoins * decimalProduct).round();

    return UtxoFromMarisma(
      txid: json['txid'] as String,
      vout: json['tx_pos'] as int,
      amount: valueInSatoshis,
    );
  }

  /// Parse a list of UTXOs from PbList
  static List<UtxoFromMarisma> fromPbList(
    List<String> data,
    String identifier,
  ) {
    return data.map((jsonString) {
      // Parse the JSON string into a Map
      final Map<String, dynamic> json = jsonDecode(jsonString);
      // Create UtxoFromMarisma from the parsed JSON
      return UtxoFromMarisma.fromJson(json, identifier);
    }).toList();
  }
}
