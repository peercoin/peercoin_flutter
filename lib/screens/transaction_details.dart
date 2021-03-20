import 'package:flutter/material.dart';
import 'package:peercoin/models/wallettransaction.dart';

class TransactionDetails extends StatelessWidget {
  static const routeName = "/tx-detail";

  @override
  Widget build(BuildContext context) {
    final WalletTransaction tx = ModalRoute.of(context).settings.arguments;
    print(tx);
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Transaction details",
      )),
      body: Column(
        children: [],
      ),
    );
  }
}
