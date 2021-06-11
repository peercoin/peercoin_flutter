import 'package:flutter/material.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/widgets/receive_tab.dart';
import 'package:peercoin/widgets/send_tab.dart';
import 'package:peercoin/widgets/transactions_list.dart';

class WalletContentSwitch extends StatelessWidget {
  late final int pageIndex;
  final List<WalletTransaction>? walletTransactions;
  late final String unusedAddress;
  late final String identifier;
  late final Function changeIndex;

  WalletContentSwitch({
    required this.pageIndex,
    required this.walletTransactions,
    required this.unusedAddress,
    required this.changeIndex,
    required this.identifier,
  });

  @override
  Widget build(BuildContext context) {
    switch (pageIndex) {
      case 0:
        return Expanded(
            child: SingleChildScrollView(child: ReceiveTab(unusedAddress)));
      case 1:
        return TransactionList(
          walletTransactions ?? [],
          identifier,
        );
      case 2:
        return Expanded(
          child: SingleChildScrollView(
            child: SendTab(
              changeIndex,
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
