import 'dart:typed_data';
import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/providers/connection_provider.dart';
import 'package:peercoin/screens/wallet/transaction_details.dart';
import 'package:peercoin/tools/generic_address.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:provider/provider.dart';

class WalletSignTransactionConfirmationArguments {
  Transaction tx;
  List<int> selectedInputs;
  int decimalProduct;
  String coinLetterCode;
  Network network;

  WalletSignTransactionConfirmationArguments({
    required this.tx,
    required this.selectedInputs,
    required this.decimalProduct,
    required this.coinLetterCode,
    required this.network,
  });
}

class WalletSignTransactionConfirmationScreen extends StatelessWidget {
  const WalletSignTransactionConfirmationScreen({super.key});
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

  List<Widget> renderInputs({
    required List<int> selectedInputs,
    required String letterCode,
    required int decimalProduct,
    required Transaction tx,
    required BuildContext context,
  }) {
    List<Widget> list = [];

    for (var input in selectedInputs) {
      final inputTxId = bytesToHex(
        Uint8List.fromList(tx.inputs[input].prevOut.hash.reversed.toList()),
      );
      list.add(
        Row(
          key: Key(input.toString()),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                inputTxId,
                style: const TextStyle(
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                selectedInputs.contains(input) ? 'Signed' : 'Not signed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selectedInputs.contains(input)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return list;
  }

  Future<void> broadcastTransaction({
    required String hex,
    required String txId,
    required BuildContext context,
  }) async {
    final connectionProvider = context.read<ConnectionProvider>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance
                .translate('sign_transaction_confirmation_dialog_title'),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.instance
                    .translate('sign_transaction_confirmation_dialog_content'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                //broadcast transaction
                connectionProvider.broadcastTransaction(
                  hex,
                  txId,
                );

                //show snack bar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.instance.translate(
                        'sign_transaction_confirmation_broadcast_snack',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );

                //close dialog
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('sign_transaction_confirmation_broadcast'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalletSignTransactionConfirmationArguments arguments =
        ModalRoute.of(context)!.settings.arguments
            as WalletSignTransactionConfirmationArguments;
    final Transaction tx = arguments.tx;
    final Map<String, int> recipients = tx.outputs
        .map(
      (e) => MapEntry(
        GenericAddress.fromAsm(e.program!.script.asm, arguments.network)
            .toString(),
        e.value,
      ),
    )
        .fold<Map<String, int>>({}, (prev, element) {
      prev[element.key] = element.value.toInt();
      return prev;
    });

    final totalAmount = tx.outputs.map((e) => e.value).reduce((a, b) => a + b);
    final decimalProduct = arguments.decimalProduct;
    final selectedInputs = arguments.selectedInputs;
    final coinLetterCode = arguments.coinLetterCode;
    final txReadyForBroadcast =
        (selectedInputs.length == tx.inputs.length) && tx.complete;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance
              .translate('sign_transaction_confirmation_title'),
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
                                '${totalAmount.toInt() / decimalProduct} $coinLetterCode',
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
                            AppLocalizations.instance
                                .translate('sign_transaction_inputs'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...renderInputs(
                            selectedInputs: selectedInputs,
                            letterCode: coinLetterCode,
                            decimalProduct: decimalProduct,
                            tx: tx,
                            context: context,
                          ),
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
                            recipients: recipients,
                            letterCode: coinLetterCode,
                            decimalProduct: decimalProduct,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(),
                      Text(
                        AppLocalizations.instance
                            .translate('sign_transaction_step_3_description'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DoubleTabToClipboard(
                        clipBoardData: tx.toHex(),
                        child: SelectableText(tx.toHex()),
                      ),
                      if (txReadyForBroadcast)
                        const SizedBox(
                          height: 20,
                        ),
                      if (txReadyForBroadcast)
                        Center(
                          child: PeerButton(
                            text: AppLocalizations.instance.translate(
                              'sign_transaction_confirmation_broadcast',
                            ),
                            action: () => broadcastTransaction(
                              hex: tx.toHex(),
                              txId: tx.txid,
                              context: context,
                            ),
                          ),
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
