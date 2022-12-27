import 'package:flutter/material.dart';
import 'package:peercoin/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../models/buildresult.dart';
import '../../providers/active_wallets.dart';
import '../../providers/electrum_connection.dart';
import '../../tools/app_localizations.dart';
import '../../tools/logger_wrapper.dart';
import '../../widgets/buttons.dart';
import '../../widgets/service_container.dart';
import 'transaction_details.dart';

List<Widget> renderRecipients({
  required Map<String, int> recipients,
  required String letterCode,
  required int decimalProduct,
}) {
  List<Widget> list = [];

  recipients.forEach(
    (addr, value) => list.add(
      const TransactionDetails().renderRow(
        addr,
        value / decimalProduct,
        letterCode,
      ),
    ),
  );
  return list;
}

class TransactionConfirmationArguments {
  BuildResult buildResult;
  int decimalProduct;
  String coinLetterCode;
  String coinIdentifier;
  Function callBackAfterSend;
  double fiatPricePerCoin;
  String fiatCode;

  TransactionConfirmationArguments({
    required this.buildResult,
    required this.decimalProduct,
    required this.coinLetterCode,
    required this.coinIdentifier,
    required this.callBackAfterSend,
    required this.fiatPricePerCoin,
    required this.fiatCode,
  });
}

class TransactionConfirmationScreen extends StatefulWidget {
  const TransactionConfirmationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<TransactionConfirmationScreen> createState() =>
      _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState
    extends State<TransactionConfirmationScreen> {
  bool _firstPress = true;

  @override
  Widget build(BuildContext context) {
    final TransactionConfirmationArguments arguments = ModalRoute.of(context)!
        .settings
        .arguments as TransactionConfirmationArguments;

    final BuildResult buildResult = arguments.buildResult;
    final String coinLetterCode = arguments.coinLetterCode;
    final int decimalProduct = arguments.decimalProduct;
    int totalAmountWithFeesAndDust =
        buildResult.fee + buildResult.totalAmount + buildResult.destroyedChange;
    final bool fiatAvailable = !arguments.coinIdentifier.contains('Testnet') &&
        arguments.fiatPricePerCoin != 0;

    if (buildResult.feesHaveBeenDeductedFromRecipient) {
      //recipient output was cut to pay for fees!
      totalAmountWithFeesAndDust = buildResult.totalAmount + buildResult.fee;
    } else if (buildResult.allRecipientOutPutsAreZero) {
      totalAmountWithFeesAndDust -= buildResult.fee;
    } else if (buildResult.destroyedChange > 0) {
      totalAmountWithFeesAndDust =
          buildResult.totalAmount + buildResult.destroyedChange;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate('send_confirm_transaction'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                child: PeerContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance.translate('tx_value'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectableText(
                                '${buildResult.totalAmount / decimalProduct} $coinLetterCode',
                              ),
                              if (fiatAvailable)
                                Text(
                                  '${((buildResult.totalAmount / decimalProduct) * arguments.fiatPricePerCoin).toStringAsFixed(4)} ${arguments.fiatCode}',
                                ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance.translate('tx_fee'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectableText(
                                '${buildResult.fee / decimalProduct} $coinLetterCode',
                              ),
                              if (fiatAvailable)
                                Text(
                                  '${((buildResult.fee / decimalProduct) * arguments.fiatPricePerCoin).toStringAsFixed(4)} ${arguments.fiatCode}',
                                ),
                            ],
                          )
                        ],
                      ),
                      if (buildResult.destroyedChange > 0) const Divider(),
                      if (buildResult.destroyedChange > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.instance
                                  .translate('send_dust_title'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SelectableText(
                                  '${buildResult.destroyedChange / decimalProduct} $coinLetterCode',
                                ),
                                if (fiatAvailable)
                                  Text(
                                    '${((buildResult.destroyedChange / decimalProduct) * arguments.fiatPricePerCoin).toStringAsFixed(4)} ${arguments.fiatCode}',
                                  ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              AppLocalizations.instance
                                  .translate('send_dust_hint'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance
                                .translate('send_total_amount'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectableText(
                                '${totalAmountWithFeesAndDust / decimalProduct} $coinLetterCode',
                              ),
                              if (fiatAvailable)
                                Text(
                                  '${((totalAmountWithFeesAndDust / decimalProduct) * arguments.fiatPricePerCoin).toStringAsFixed(4)} ${arguments.fiatCode}',
                                ),
                            ],
                          )
                        ],
                      ),
                      const Divider(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.instance
                                .translate('tx_recipients'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...renderRecipients(
                            recipients: buildResult.recipients,
                            letterCode: coinLetterCode,
                            decimalProduct: decimalProduct,
                          )
                        ],
                      ),
                      buildResult.opReturn.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                Text(
                                  AppLocalizations.instance
                                      .translate('send_op_return'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SelectableText(buildResult.opReturn)
                              ],
                            )
                          : const SizedBox(),
                      const Divider(),
                      buildResult.feesHaveBeenDeductedFromRecipient
                          ? Text(
                              AppLocalizations.instance
                                  .translate('send_fees_deducted'),
                              style: TextStyle(
                                color: Theme.of(context).errorColor,
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _firstPress == false
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width >
                                          1200
                                      ? MediaQuery.of(context).size.width / 3
                                      : MediaQuery.of(context).size.width / 2,
                                  child: const LoadingIndicator(),
                                )
                              : PeerButton(
                                  text: AppLocalizations.instance.translate(
                                    'send_confirm_send',
                                  ),
                                  action: () async {
                                    if (_firstPress == false) return;
                                    setState(() {
                                      _firstPress = false;
                                    });
                                    final electrumConnection =
                                        context.read<ElectrumConnection>();
                                    final activeWallets =
                                        context.read<ActiveWallets>();
                                    final navigator = Navigator.of(context);
                                    try {
                                      //write tx to history
                                      await activeWallets.putOutgoingTx(
                                        identifier: arguments.coinIdentifier,
                                        buildResult: buildResult,
                                        totalFees: buildResult.fee,
                                        totalValue: buildResult
                                                .allRecipientOutPutsAreZero
                                            ? 0
                                            : buildResult.totalAmount,
                                      );
                                      //broadcast
                                      electrumConnection.broadcastTransaction(
                                        buildResult.hex,
                                        buildResult.id,
                                      );
                                      //flag inputUtxos as locked
                                      for (var element in buildResult.inputTx) {
                                        element.newHeight = -1;
                                      }
                                      //update balance
                                      await activeWallets.updateWalletBalance(
                                        arguments.coinIdentifier,
                                      );
                                      //pop message
                                      navigator.pop();
                                      //navigate back to tx list
                                      arguments.callBackAfterSend();
                                    } catch (e) {
                                      LoggerWrapper.logError(
                                        'SendTab',
                                        'showTransactionConfirmation',
                                        e.toString(),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.instance.translate(
                                              'send_oops',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
