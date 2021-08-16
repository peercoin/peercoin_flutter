import 'package:flutter/material.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:intl/intl.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatefulWidget {
  final List<WalletTransaction> _walletTransactions;
  final _wallet;
  final _filterChoice;
  TransactionList(
      this._walletTransactions, this._wallet, this._filterChoice);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {

  String resolveAddressDisplayName(String address) {
    final result = context
        .read<ActiveWallets>()
        .getLabelForAddress(widget._wallet.name, address);
    if (result != '') return '$result';
    return address;
  }

  Widget renderConfirmationIndicator(WalletTransaction tx) {
    if (tx.confirmations == -1) {
      return Text(
        'X',
        textScaleFactor: 0.9,
        style: TextStyle(color: Colors.red),
      );
    }
    return tx.broadCasted == false
        ? Text(
            '?',
            textScaleFactor: 0.9,
            style: TextStyle(color: Theme.of(context).accentColor),
          )
        : CircularStepProgressIndicator(
            selectedStepSize: 5,
            unselectedStepSize: 5,
            totalSteps: 6,
            currentStep: tx.confirmations,
            width: 20,
            height: 20,
            selectedColor: Theme.of(context).primaryColor,
            unselectedColor:
                Theme.of(context).unselectedWidgetColor.withOpacity(0.5),
            stepSize: 4,
            roundedCap: (_, __) => true,
          );
  }

  @override
  Widget build(BuildContext context) {
    var _reversedTx = widget._walletTransactions
        .where((element) => element.timestamp != -1) //filter "phantom" tx
        .toList()
        .reversed
        .toList();
    if(_reversedTx.isEmpty){
      _reversedTx.add(
        WalletTransaction(txid: 'Fake_in_transaction', timestamp: 1628946473, value: 10000000, fee: 10000, address: 'your address', direction: 'in', broadCasted: true, broadcastHex: ' ', confirmations: 6)
      );
      _reversedTx.add(
          WalletTransaction(txid: 'Fake_out_transaction', timestamp: 1628946473, value: 10000000, fee: 10000, address: 'contact address', direction: 'out', broadCasted: true, broadcastHex: ' ', confirmations: 6)
      );
    }
    var _filteredTx = _reversedTx;
    if (widget._filterChoice != 'all') {
      _filteredTx = _reversedTx
          .where((element) => element.direction == widget._filterChoice)
          .toList();
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int i) {
          return Card(
            child: ListTile(
              horizontalTitleGap: 32.0,
              onTap: () => Navigator.of(context)
                  .pushNamed(Routes.Transaction, arguments: [
                _filteredTx[i],
                ModalRoute.of(context)!.settings.arguments
              ]),
              leading: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      child: renderConfirmationIndicator(
                        _filteredTx[i],
                      ),
                    ),
                    Text(
                      DateFormat('d. MMM').format(
                          _filteredTx[i].timestamp != 0
                              ? DateTime
                              .fromMillisecondsSinceEpoch(
                              _filteredTx[i]
                                  .timestamp! *
                                  1000)
                              : DateTime.now()),
                      style: TextStyle(
                        fontWeight:
                        _filteredTx[i].timestamp != 0
                            ? FontWeight.w500
                            : FontWeight.w300,
                        fontSize: 14,
                      ),
                      textScaleFactor: 0.8,
                    )
                  ]),
              title: Center(
                child: Text(
                  _filteredTx[i].txid,
                  overflow: TextOverflow.ellipsis,
                  //textScaleFactor: 0.9,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              subtitle: Center(
                child: Text(
                  resolveAddressDisplayName(
                      _filteredTx[i].address),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (_filteredTx[i].direction == 'in'
                        ? '+'
                        : '-') +
                        (_filteredTx[i].value / 1000000)
                            .toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight:
                      _filteredTx[i].timestamp != 0
                          ? FontWeight.bold
                          : FontWeight.w300,
                      color: _filteredTx[i].direction == 'out'
                          ? Theme.of(context).errorColor
                          : Theme.of(context).bottomAppBarColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: _filteredTx.length,
      ),
    );
  }
}
