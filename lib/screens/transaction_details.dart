import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetails extends StatelessWidget {
  static const routeName = "/tx-detail";

  void _launchURL(_url) async {
    print(_url);
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List;
    final WalletTransaction _tx = args[0];
    final CoinWallet _coinWallet = args[1];
    final String baseUrl =
        AvailableCoins().getSpecificCoin(_coinWallet.name).explorerTxDetailUrl;

    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "Transaction details",
      )),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Id", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_tx.txid)
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text(
                "Value",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText((_tx.value / 1000000).toString() +
                  " " +
                  _coinWallet.letterCode)
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Fee", style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(
                  (_tx.fee / 1000000).toString() + " " + _coinWallet.letterCode)
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Address",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_tx.address)
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Direction",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_tx.direction)
            ],
          ),
          Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Confirmations",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_tx.confirmations.toString())
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: TextButton.icon(
                onPressed: () => _launchURL(baseUrl + "${_tx.txid}"),
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  "View in explorer",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )),
          )
        ],
      ),
    );
  }
}
