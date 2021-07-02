import 'package:flutter/material.dart';
import 'package:peercoin/providers/activewallets.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:intl/intl.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/widgets/wallet_home_connection.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatefulWidget {
  final List<WalletTransaction> _walletTransactions;
  final _wallet;
  final _connectionState;
  TransactionList(this._walletTransactions, this._wallet, this._connectionState);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  String _filterChoice = 'all';

  void _handleSelect(String newChoice) {
    setState(() {
      _filterChoice = newChoice;
    });
  }

  String resolveAddressDisplayName(String address) {
    final result = context
        .read<ActiveWallets>()
        .getLabelForAddress(widget._wallet.name, address);
    if (result != '') return '$result (${address.substring(0, 5)}...)';
    return address;
  }

  @override
  Widget build(BuildContext context) {
    var _reversedTx = widget._walletTransactions
        .where((element) => element.timestamp != -1) //filter phatom tx
        .toList()
        .reversed
        .toList();
    var _filteredTx = _reversedTx;
    if (_filterChoice != 'all') {
      _filteredTx = _reversedTx
          .where((element) => element.direction == _filterChoice)
          .toList();
    }

    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 32,),
            WalletHomeConnection(widget._connectionState),
            SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      (widget._wallet.balance / 1000000).toString(),
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[100],
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    widget._wallet.unconfirmedBalance > 0
                        ? Text(
                            (widget._wallet.unconfirmedBalance / 1000000)
                                .toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[100],
                            ),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  widget._wallet.letterCode,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ],
        ),
        widget._walletTransactions.isEmpty
            ? Center(
                child: Text(
                AppLocalizations.instance.translate('transactions_list'),
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).backgroundColor),
              ))
            : GestureDetector(
                onHorizontalDragEnd: (dragEndDetails) {
                  if (dragEndDetails.primaryVelocity! < 0) {
                    //left swipe
                    if (_filterChoice == 'in') {
                      _handleSelect('all');
                    } else if (_filterChoice == 'all') {
                      _handleSelect('out');
                    }
                  } else if (dragEndDetails.primaryVelocity! > 0) {
                    //right swipe
                    if (_filterChoice == 'out') {
                      _handleSelect('all');
                    } else if (_filterChoice == 'all') {
                      _handleSelect('in');
                    }
                  }
                },
                child: ListView.builder(
                  itemCount: _filteredTx.length + 1,
                  itemBuilder: (_, i) {
                    var currentConfirmations;
                    if (i > 0) {
                      currentConfirmations = _filteredTx[i - 1].confirmations;
                      return Container(
                        color: Theme.of(context).primaryColor,
                        child: Card(
                          child: ListTile(
                            onTap: () => Navigator.of(context)
                                .pushNamed(Routes.Transaction, arguments: [
                              _filteredTx[i - 1],
                              ModalRoute.of(context)!.settings.arguments
                            ]),
                            leading: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      child: _filteredTx[i - 1].broadCasted ==
                                              false
                                          ? Text('?',
                                              textScaleFactor: 0.9,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor))
                                          : CircularStepProgressIndicator(
                                              selectedStepSize: 5,
                                              unselectedStepSize: 5,
                                              totalSteps: 6,
                                              currentStep: currentConfirmations,
                                              width: 20,
                                              height: 20,
                                              selectedColor: Theme.of(context)
                                                  .primaryColor,
                                              unselectedColor:
                                                  Theme.of(context).unselectedWidgetColor.withOpacity(0.5),
                                              stepSize: 4,
                                              roundedCap: (_, __) => true,
                                            )),
                                  Text(
                                    DateFormat('d. MMM').format(
                                        _filteredTx[i - 1].timestamp != null
                                            ? DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    _filteredTx[i - 1]
                                                            .timestamp! *
                                                        1000)
                                            : DateTime.now()),
                                    style: TextStyle(
                                      fontWeight:
                                          _filteredTx[i - 1].timestamp != null
                                              ? FontWeight.w500
                                              : FontWeight.w300,
                                    ),
                                    textScaleFactor: 0.8,
                                  )
                                ]),
                            title: Center(
                              child: Text(
                                _filteredTx[i - 1].txid,
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 0.9,
                              ),
                            ),
                            subtitle: Center(
                              child: Text(
                                resolveAddressDisplayName(
                                    _filteredTx[i - 1].address),
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (_filteredTx[i - 1].direction == 'in'
                                          ? '+'
                                          : '-') +
                                      (_filteredTx[i - 1].value / 1000000)
                                          .toString(),
                                  style: TextStyle(
                                      fontWeight:
                                          _filteredTx[i - 1].timestamp != null
                                              ? FontWeight.bold
                                              : FontWeight.w300,
                                      color:
                                          _filteredTx[i - 1].direction == 'out'
                                              ? Theme.of(context).errorColor
                                              : Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (i == 0 && widget._walletTransactions.isNotEmpty) {
                      return Column(
                        children: [
                          SizedBox(height: 130),
                          Wrap(
                            spacing: 8.0,
                            children: <Widget>[
                              ChoiceChip(
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                selectedColor: Theme.of(context).shadowColor,
                                visualDensity: VisualDensity(
                                    horizontal: 0.0, vertical: -4),
                                label: Container(
                                    child: Text(
                                  AppLocalizations.instance
                                      .translate('transactions_in'),
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                )),
                                selected: _filterChoice == 'in',
                                onSelected: (_) => _handleSelect('in'),
                              ),
                              ChoiceChip(
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                selectedColor: Theme.of(context).shadowColor,
                                visualDensity: VisualDensity(
                                    horizontal: 0.0, vertical: -4),
                                label: Text(
                                    AppLocalizations.instance
                                        .translate('transactions_all'),
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    )),
                                selected: _filterChoice == 'all',
                                onSelected: (_) => _handleSelect('all'),
                              ),
                              ChoiceChip(
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                selectedColor: Theme.of(context).shadowColor,
                                visualDensity: VisualDensity(
                                    horizontal: 0.0, vertical: -4),
                                label: Text(
                                    AppLocalizations.instance
                                        .translate('transactions_out'),
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    )),
                                selected: _filterChoice == 'out',
                                onSelected: (_) => _handleSelect('out'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
      ],
    );
  }
}
