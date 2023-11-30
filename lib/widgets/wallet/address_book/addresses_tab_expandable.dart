import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../models/hive/wallet_address.dart';
import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';
import '../../double_tab_to_clipboard.dart';
import '../wallet_home_qr.dart';

class AddressTabExpandable extends StatelessWidget {
  final WalletAddress walletAddress;
  final String walletName;
  final AddressTabSlideableType type;
  final Function applyFilterCallback;
  final double balance;
  final String balanceUnit;

  const AddressTabExpandable({
    super.key,
    required this.walletAddress,
    required this.walletName,
    required this.type,
    required this.balance,
    required this.applyFilterCallback,
    required this.balanceUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 1200
            ? MediaQuery.of(context).size.width / 3
            : MediaQuery.of(context).size.width,
        child: DoubleTabToClipboard(
          clipBoardData: walletAddress.address,
          child: Card(
            elevation: 0,
            child: ClipRect(
              child: ExpansionTile(
                title: Text(
                  walletAddress.address,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  walletAddress.addressBookName.isEmpty
                      ? AppLocalizations.instance
                          .translate('addressbook_no_label')
                      : walletAddress.addressBookName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12,
                  ),
                ),
                key: Key(walletAddress.address),
                children: <Widget>[
                  Column(
                    children: [
                      Text('Balance: $balance $balanceUnit'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_edit'),
                    color: Theme.of(context).primaryColor,
                    icon: Icons.edit,
                    onTap: () => _addressEditDialog(context, walletAddress),
                  ),
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_share'),
                    color: Theme.of(context).colorScheme.background,
                    iconWidget: Icon(
                      Icons.share,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () => WalletHomeQr.showQrDialog(
                      context,
                      walletAddress.address,
                    ),
                  ),
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_delete'),
                    color: Theme.of(context).colorScheme.error,
                    iconWidget: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            AppLocalizations.instance.translate(
                              'addressbook_dialog_remove_title',
                            ),
                          ),
                          content: Text(walletAddress.address),
                          actions: <Widget>[
                            TextButton.icon(
                              label: Text(
                                AppLocalizations.instance.translate(
                                  'server_settings_alert_cancel',
                                ),
                              ),
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton.icon(
                              label: Text(
                                AppLocalizations.instance.translate(
                                  'jail_dialog_button',
                                ),
                              ),
                              icon: const Icon(Icons.check),
                              onPressed: () async {
                                await _performAddressDelete(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addressEditDialog(
    BuildContext context,
    WalletAddress address,
  ) async {
    var textFieldController = TextEditingController();
    textFieldController.text = address.addressBookName;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${AppLocalizations.instance.translate('addressbook_edit_dialog_title')} ${address.address}',
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: textFieldController,
            maxLength: 32,
            decoration: InputDecoration(
              hintText: AppLocalizations.instance
                  .translate('addressbook_edit_dialog_input'),
            ),
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
              onPressed: () {
                context.read<WalletProvider>().updateOrCreateAddressLabel(
                      identifier: walletName,
                      address: address.address,
                      label: textFieldController.text,
                    );
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performAddressDelete(BuildContext context) async {
    final WalletProvider walletProvider = context.read<WalletProvider>();

    await walletProvider.removeWatchOnlyAddress(
      walletName,
      walletAddress,
    );
    if (!context.mounted) return;

    applyFilterCallback();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate(
            'addressbook_dialog_remove_snack',
          ),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(
          seconds: 5,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  String _renderLabel(WalletAddress addr) {
    return '';
    // if (_showLabel) {
    //   return addr.addressBookName;
    // }
    // var number = _addressBalanceMap[addr.address] ?? 0;
    // return '${(number / _decimalProduct)} ${_availableCoin.letterCode}';
  }
}

//TODO migrate filter options
enum AddressTabSlideableType { receive, send, watchOnly }
