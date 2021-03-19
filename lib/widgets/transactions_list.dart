import "package:flutter/material.dart";
import 'package:peercoin/models/wallettransaction.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class TransactionList extends StatelessWidget {
  final List<WalletTransaction> _walletTransactions;
  TransactionList(this._walletTransactions);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _walletTransactions.length == 0
          ? Center(
              child: const Text("No transactions yet"),
            )
          : ListView.builder(
              itemCount: _walletTransactions.length,
              itemBuilder: (_, i) {
                List<WalletTransaction> _flippedTx =
                    _walletTransactions.reversed.toList();
                int currentConfirmations = _flippedTx[i].confirmations;

                return Card(
                  child: ListTile(
                    leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _flippedTx[i].direction == "in"
                                ? Icons.west
                                : Icons.east,
                            size: 18,
                          ),
                          AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              child: _flippedTx[i].broadCasted == false
                                  ? Text("?",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).accentColor))
                                  : CircularStepProgressIndicator(
                                      totalSteps: 6,
                                      currentStep: currentConfirmations,
                                      width: 20,
                                      height: 20,
                                      selectedColor:
                                          Theme.of(context).primaryColor,
                                      unselectedColor:
                                          Theme.of(context).accentColor,
                                      stepSize: 4,
                                      roundedCap: (_, __) => true,
                                    )),
                          Text(
                            DateFormat("d. MMM").format(
                                _flippedTx[i].timestamp != null
                                    ? DateTime.fromMillisecondsSinceEpoch(
                                        _flippedTx[i].timestamp * 1000)
                                    : DateTime.now()),
                            style: TextStyle(
                              fontWeight: _flippedTx[i].timestamp != null
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                            ),
                          )
                        ]),
                    title: Center(
                      child: Text(
                        _flippedTx[i].txid,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: Center(
                      child: Text(
                        _flippedTx[i].address,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (_flippedTx[i].direction == "in" ? "+" : "-") +
                              (_flippedTx[i].value / 1000000).toString(),
                          style: TextStyle(
                              fontWeight: _flippedTx[i].timestamp != null
                                  ? FontWeight.bold
                                  : FontWeight.w300,
                              color: _flippedTx[i].direction == "out"
                                  ? Colors.redAccent.shade200
                                  : Colors.black),
                        ),
                        if (_flippedTx[i].direction == "out")
                          Text(
                            "-" +
                                (_flippedTx[i].fee / 1000000).toString() +
                                "\nFee",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).accentColor),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
