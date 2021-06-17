import 'package:flutter/material.dart';
import 'package:peercoin/models/walletaddress.dart';
import 'package:peercoin/models/wallettransaction.dart';
import 'package:peercoin/widgets/addresses_tab.dart';
import 'package:peercoin/widgets/receive_tab.dart';
import 'package:peercoin/widgets/send_tab.dart';
import 'package:peercoin/widgets/transactions_list.dart';

class WalletContentSwitch extends StatelessWidget {
  final int pageIndex;
  final List<WalletTransaction> walletTransactions;
  final List<WalletAddress> walletAddresses;
  final String unusedAddress;
  final String identifier;
  final Function changeIndex;
  final String title;

  WalletContentSwitch({
    this.pageIndex,
    this.walletTransactions,
    this.walletAddresses,
    this.unusedAddress,
    this.changeIndex,
    this.identifier,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    switch (pageIndex) {
      case 0:
        return Expanded(
            child: ReceiveTab(unusedAddress));
      case 1:
        return Expanded(
          child: TransactionList(
            walletTransactions ?? [],
            identifier,
          ),
        );
      case 2:
        return Expanded(
            child: AddressTab(identifier, title, walletAddresses ?? [],(){}));
      case 3:
        return Expanded(
          child: SingleChildScrollView(
            child: SendTab(
              changeIndex,
              'string',
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
