import 'package:flutter/material.dart';
import 'package:peercoin/models/buildresult.dart';

import '../../tools/app_localizations.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  const TransactionConfirmationScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('send_confirm_transaction'),
        ),
      ),
    );
  }
}
