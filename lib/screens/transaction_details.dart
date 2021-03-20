import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/models/wallettransaction.dart';

class TransactionDetails extends StatelessWidget {
  static const routeName = "/tx-detail";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List;
    final WalletTransaction _tx = args[0];
    final CoinWallet _coinWallet = args[1];

    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Transaction details",
      )),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("Id"), SelectableText(_tx.txid)],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Time"),
              SelectableText(_tx.timestamp != null
                  ? DateFormat().format(
                      DateTime.fromMillisecondsSinceEpoch(_tx.timestamp * 1000))
                  : "unconfirmed")
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Value"),
              SelectableText((_tx.value / 1000000).toString() +
                  " " +
                  _coinWallet.letterCode)
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fee"),
              SelectableText(
                  (_tx.fee / 1000000).toString() + " " + _coinWallet.letterCode)
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("Address"), SelectableText(_tx.address)],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text("Direction"), SelectableText(_tx.direction)],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Confirmations"),
              SelectableText(_tx.confirmations.toString())
            ],
          ),
        ],
      ),
    );
  }
}
