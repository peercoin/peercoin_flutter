import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin_wallet.dart';
import '../../providers/electrum_connection.dart';
import '/../providers/active_wallets.dart';
import '/../tools/app_localizations.dart';
import '/../models/wallet_transaction.dart';
import '/../tools/app_routes.dart';
import '/../widgets/wallet/wallet_balance_header.dart';
import '/../widgets/service_container.dart';

class TransactionList extends StatefulWidget {
  final List<WalletTransaction> _walletTransactions;
  final CoinWallet _wallet;
  final ElectrumConnectionState _connectionState;

  const TransactionList(
      this._walletTransactions, this._wallet, this._connectionState,
      {Key? key})
      : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  String _filterChoice = 'all';
  late final int _decimalProduct;

  void _handleSelect(String newChoice) {
    setState(() {
      _filterChoice = newChoice;
    });
  }

  @override
  void initState() {
    _decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: widget._wallet.name,
    );
    super.initState();
  }

  String resolveAddressDisplayName(String address) {
    final result = context
        .read<ActiveWallets>()
        .getLabelForAddress(widget._wallet.name, address);
    if (result != '') return result;
    return address;
  }

  Widget renderConfirmationIndicator(WalletTransaction tx) {
    if (tx.confirmations == -1) {
      return const Text(
        'X',
        textScaleFactor: 0.9,
        style: TextStyle(color: Colors.red),
      );
    }
    return tx.broadCasted == false
        ? Text(
            '?',
            textScaleFactor: 0.9,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
    var reversedTx = widget._walletTransactions
        .where((element) => element.timestamp != -1) //filter "phantom" tx
        .toList()
        .reversed
        .toList();
    var filteredTx = reversedTx;
    if (_filterChoice != 'all') {
      filteredTx = reversedTx
          .where((element) => element.direction == _filterChoice)
          .toList();
    }

    return Stack(
      children: [
        WalletBalanceHeader(widget._connectionState, widget._wallet),
        widget._walletTransactions
                .where(
                  (element) => element.timestamp != -1,
                ) //don't count "phantom" tx
                .isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 8,
                  ),
                  Image.asset(
                    'assets/img/list-empty.png',
                    height: MediaQuery.of(context).size.height / 4,
                  ),
                  Center(
                    child: Text(
                      AppLocalizations.instance.translate('transactions_none'),
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                ],
              )
            : Align(
                child: PeerContainer(
                  isTransparent: true,
                  noSpacers: true,
                  child: GestureDetector(
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
                      itemCount: filteredTx.length + 1,
                      itemBuilder: (_, i) {
                        if (i > 0) {
                          return Container(
                            color: Theme.of(context).primaryColor,
                            child: Card(
                              elevation: 0,
                              child: ListTile(
                                horizontalTitleGap: 32.0,
                                onTap: () => Navigator.of(context)
                                    .pushNamed(Routes.transaction, arguments: [
                                  filteredTx[i - 1],
                                  ModalRoute.of(context)!.settings.arguments
                                ]),
                                leading: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: renderConfirmationIndicator(
                                        filteredTx[i - 1],
                                      ),
                                    ),
                                    Text(
                                      DateFormat('d. MMM').format(
                                        filteredTx[i - 1].timestamp != 0
                                            ? DateTime
                                                .fromMillisecondsSinceEpoch(
                                                filteredTx[i - 1].timestamp! *
                                                    1000,
                                              )
                                            : DateTime.now(),
                                      ),
                                      style: TextStyle(
                                        fontWeight:
                                            filteredTx[i - 1].timestamp != 0
                                                ? FontWeight.w500
                                                : FontWeight.w300,
                                      ),
                                      textScaleFactor: 0.8,
                                    )
                                  ],
                                ),
                                title: Center(
                                  child: Text(
                                    filteredTx[i - 1].txid,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 0.9,
                                  ),
                                ),
                                subtitle: Center(
                                  child: Text(
                                    resolveAddressDisplayName(
                                        filteredTx[i - 1].address),
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (filteredTx[i - 1].direction == 'in'
                                              ? '+'
                                              : '-') +
                                          (filteredTx[i - 1].value /
                                                  _decimalProduct)
                                              .toString(),
                                      style: TextStyle(
                                        fontWeight:
                                            filteredTx[i - 1].timestamp != 0
                                                ? FontWeight.bold
                                                : FontWeight.w300,
                                        color:
                                            filteredTx[i - 1].direction == 'out'
                                                ? Theme.of(context).errorColor
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                      ),
                                    ),
                                    filteredTx[i - 1].direction == 'out'
                                        ? Text(
                                            '-${filteredTx[i - 1].fee / _decimalProduct}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                              color:
                                                  Theme.of(context).errorColor,
                                              fontSize: 12,
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 0,
                                          )
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (i == 0 &&
                            widget._walletTransactions.isNotEmpty) {
                          return Column(
                            children: [
                              SizedBox(
                                height: widget._wallet.unconfirmedBalance > 0
                                    ? 125
                                    : 110,
                              ),
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).bottomAppBarColor,
                                        Theme.of(context).primaryColor,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                ),
                              ),
                              Container(
                                color: Theme.of(context).primaryColor,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Wrap(
                                    spacing: 8.0,
                                    children: <Widget>[
                                      ChoiceChip(
                                        backgroundColor:
                                            Theme.of(context).backgroundColor,
                                        selectedColor:
                                            Theme.of(context).shadowColor,
                                        visualDensity: const VisualDensity(
                                            horizontal: 0.0, vertical: -4),
                                        label: Text(
                                          AppLocalizations.instance
                                              .translate('transactions_in'),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        selected: _filterChoice == 'in',
                                        onSelected: (_) => _handleSelect('in'),
                                      ),
                                      ChoiceChip(
                                        backgroundColor:
                                            Theme.of(context).backgroundColor,
                                        selectedColor:
                                            Theme.of(context).shadowColor,
                                        visualDensity: const VisualDensity(
                                            horizontal: 0.0, vertical: -4),
                                        label: Text(
                                            AppLocalizations.instance
                                                .translate('transactions_all'),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            )),
                                        selected: _filterChoice == 'all',
                                        onSelected: (_) => _handleSelect('all'),
                                      ),
                                      ChoiceChip(
                                        backgroundColor:
                                            Theme.of(context).backgroundColor,
                                        selectedColor:
                                            Theme.of(context).shadowColor,
                                        visualDensity: const VisualDensity(
                                            horizontal: 0.0, vertical: -4),
                                        label: Text(
                                            AppLocalizations.instance
                                                .translate('transactions_out'),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            )),
                                        selected: _filterChoice == 'out',
                                        onSelected: (_) => _handleSelect('out'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 10,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
