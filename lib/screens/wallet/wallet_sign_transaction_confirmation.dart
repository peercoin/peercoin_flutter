import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/screens/wallet/transaction_details.dart';
import 'package:peercoin/tools/address_from_asm.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/double_tab_to_clipboard.dart';
import 'package:peercoin/widgets/service_container.dart';

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
                                '${totalAmount.toInt() / decimalProduct} $coinLetterCode',
                              ),
                            ],
                          ),
                        ],
                      ),
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
                      DoubleTabToClipboard(
                        clipBoardData: tx.toHex(),
                        child: Text(tx.toHex()),
                      )
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
  //TODO Show signed transaction inputs
}
