import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/loading_indicator.dart';

class WalletHomeConnection extends StatelessWidget {
  final String _connectionState;
  WalletHomeConnection(this._connectionState);
  @override
  Widget build(BuildContext context) {
    return _connectionState == "connected"
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sync,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                AppLocalizations.instance.translate('wallet_connected'),
                style: TextStyle(
                    color: Theme.of(context).accentColor, fontSize: 12),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: LoadingIndicator(),
          );
  }
}
