import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/available_coins.dart';
import '../../models/coin_wallet.dart';
import '../../models/wallet_transaction.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/buttons.dart';
import '../../widgets/service_container.dart';

class TransactionDetails extends StatelessWidget {
  const TransactionDetails({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(
            url,
          )
        : throw 'Could not launch $url';
  }

  List<Widget> renderRecipients({
    required WalletTransaction tx,
    required String letterCode,
    required int decimalProduct,
  }) {
    List<Widget> list = [];

    Widget renderRow(String addr, double value) {
      return Row(
        key: Key(addr),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              addr,
              style: const TextStyle(
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text('$value $letterCode'),
          ),
        ],
      );
    }

    if (tx.recipients.isEmpty) {
      list.add(
        renderRow(tx.address, tx.value / decimalProduct),
      );
    }
    tx.recipients.forEach(
      (addr, value) => list.add(
        renderRow(addr, value / decimalProduct),
      ),
    );
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final WalletTransaction tx = args['tx'];
    final CoinWallet coinWallet = args['wallet'];
    final baseUrl =
        '${AvailableCoins.getSpecificCoin(coinWallet.name).explorerUrl}/tx/';
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: coinWallet.name,
    );

    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.instance.translate('transaction_details'),
      )),
      body: Align(
        child: PeerContainer(
          noSpacers: true,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('id'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(tx.txid)
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('time'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    tx.timestamp! != 0
                        ? DateFormat().format(
                            DateTime.fromMillisecondsSinceEpoch(
                              tx.timestamp! * 1000,
                            ),
                          )
                        : AppLocalizations.instance.translate('unconfirmed'),
                  )
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_value'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    '${tx.value / decimalProduct} ${coinWallet.letterCode}',
                  )
                ],
              ),
              tx.direction == 'out'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          AppLocalizations.instance.translate('tx_fee'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          '${tx.fee / decimalProduct} ${coinWallet.letterCode}',
                        )
                      ],
                    )
                  : Container(),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_recipients'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...renderRecipients(
                    tx: tx,
                    letterCode: coinWallet.letterCode,
                    decimalProduct: decimalProduct,
                  )
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_direction'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(tx.direction)
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_confirmations'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    tx.confirmations == -1
                        ? AppLocalizations.instance.translate('tx_rejected')
                        : tx.confirmations.toString(),
                  )
                ],
              ),
              tx.opReturn.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          AppLocalizations.instance.translate('send_op_return'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(tx.opReturn)
                      ],
                    )
                  : Container(),
              const SizedBox(height: 20),
              Center(
                child: PeerButton(
                  action: () => _launchURL(baseUrl + tx.txid),
                  text: AppLocalizations.instance
                      .translate('tx_view_in_explorer'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
