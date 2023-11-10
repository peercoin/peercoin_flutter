import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../models/hive/wallet_address.dart';
import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';
import '../../double_tab_to_clipboard.dart';
import '../wallet_home_qr.dart';

enum AddressTabSlideableType { receive, send, watchOnly }

class AddressTabSlideable extends StatelessWidget {
  final WalletAddress walletAddress;
  final String walletName;
  final AddressTabSlideableType type;

  const AddressTabSlideable({
    super.key,
    required this.walletAddress,
    required this.walletName,
    required this.type,
  });

  void _addressEditDialog(BuildContext ctx, dynamic _) {}
  String _renderLabel(dynamic _) {
    return '';
  }

  void _applyFilter() {}

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
              child: Slidable(
                key: Key(walletAddress.address),
                actionPane: const SlidableScrollActionPane(),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: AppLocalizations.instance
                        .translate('addressbook_swipe_edit'),
                    color: Theme.of(context).primaryColor,
                    icon: Icons.edit,
                    onTap: () =>
                        _addressEditDialog(context, walletAddress.address),
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
                              onPressed: () {
                                context.read<WalletProvider>().removeAddress(
                                      walletName,
                                      walletAddress,
                                    );
                                _applyFilter();
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
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                actionExtentRatio: 0.25,
                child: ListTile(
                  leading: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_left),
                    ],
                  ),
                  subtitle: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Center(
                      child: Text(walletAddress.address),
                    ),
                  ),
                  title: Center(
                    child: Text(
                      _renderLabel(walletAddress),
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
