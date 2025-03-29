import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/models/hive/wallet_address.dart';
import 'package:peercoin/providers/wallet_provider.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/validators.dart';
import 'package:peercoin/widgets/wallet/wallet_home/wallet_home_qr.dart';
import 'package:provider/provider.dart';

Future<void> addressEditDialog(
  BuildContext context,
  WalletAddress address,
  String walletName,
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

Future<void> addressAddDialog({
  required BuildContext context,
  required List<WalletAddress> walletAddresses,
  required String walletName,
  required Function applyFilter,
  required Network coin,
}) async {
  var labelController = TextEditingController();
  var addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.instance.translate('addressbook_add_new'),
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.instance.translate('send_address'),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.instance
                        .translate('send_enter_address');
                  }
                  var sanitized = value.trim();
                  if (validateAddress(
                        sanitized,
                        coin,
                      ) ==
                      false) {
                    return AppLocalizations.instance
                        .translate('send_invalid_address');
                  }
                  //check if already exists
                  if (walletAddresses
                      .any((element) => element.address == value)) {
                    return 'Address already exists';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: labelController,
                maxLength: 32,
                decoration: InputDecoration(
                  hintText: AppLocalizations.instance.translate('send_label'),
                ),
              ),
            ],
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
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                context.read<WalletProvider>().updateOrCreateAddressLabel(
                      identifier: walletName,
                      address: addressController.text,
                      label: labelController.text == ''
                          ? ''
                          : labelController.text,
                    );
                applyFilter();
                Navigator.pop(context);
              }
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

Future<void> addressExportDialog({
  required BuildContext context,
  required WalletAddress address,
  required String identifier,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          AppLocalizations.instance
              .translate('addressbook_export_dialog_title'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.instance
                  .translate('addressbook_export_dialog_description'),
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
              String wif;
              final navigator = Navigator.of(context);
              void showQrDialog(wif) => WalletHomeQr.showQrDialog(context, wif);

              if (address.wif.isEmpty) {
                wif = await context.read<WalletProvider>().getWif(
                      identifier: identifier,
                      address: address.address,
                    );
              } else {
                wif = address.wif;
              }
              navigator.pop();
              showQrDialog(wif);
            },
            child: Text(
              AppLocalizations.instance
                  .translate('addressbook_export_dialog_button'),
            ),
          ),
        ],
      );
    },
  );
}
