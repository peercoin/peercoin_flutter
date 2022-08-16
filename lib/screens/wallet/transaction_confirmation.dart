import 'package:flutter/material.dart';
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

  TransactionConfirmationArguments({
    required this.buildResult,
    required this.decimalProduct,
    required this.coinLetterCode,
    required this.coinIdentifier,
    required this.callBackAfterSend,
  });
}

class TransactionConfirmationScreen extends StatelessWidget {
  const TransactionConfirmationScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransactionConfirmationArguments arguments = ModalRoute.of(context)!
        .settings
        .arguments as TransactionConfirmationArguments;

    final BuildResult buildResult = arguments.buildResult;
    final String coinLetterCode = arguments.coinLetterCode;
    final int decimalProduct = arguments.decimalProduct;

    return Scaffold(
      appBar: AppBar(
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            '${buildResult.totalAmount / decimalProduct} $coinLetterCode',
                          )
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
                          SelectableText(
                            '${arguments.buildResult.fee / decimalProduct} $coinLetterCode',
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
                                      fontWeight: FontWeight.bold),
                                ),
                                SelectableText(buildResult.opReturn)
                              ],
                            )
                          : const SizedBox(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PeerButton(
                            text: AppLocalizations.instance.translate(
                              'send_confirm_send',
                            ),
                            action: () async {
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
                                  totalValue: buildResult.totalAmount,
                                );
                                //broadcast
                                electrumConnection.broadcastTransaction(
                                  buildResult.hex,
                                  buildResult.id,
                                );
                                //pop message
                                navigator.pop(true);
                                //navigate back to tx list
                                arguments.callBackAfterSend();
                              } catch (e) {
                                LoggerWrapper.logError(
                                  'SendTab',
                                  'showTransactionConfirmation',
                                  e.toString(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
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
  //TODO show FIAT values if coming from FIAT
  //TODO test scrollview with xyz recipients
  //TODO destroyedChange: destroyedChange,
  //TODO neededChange: needsChange,
}
