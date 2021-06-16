import 'package:flutter/material.dart';
import 'package:peercoin/providers/electrumconnection.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/loading_indicator.dart';

class WalletHomeConnection extends StatelessWidget {
  final ElectrumConnectionState _connectionState;
  WalletHomeConnection(this._connectionState);
  @override
  Widget build(BuildContext context) {
    if (_connectionState == ElectrumConnectionState.connected) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.offline_bolt,
            color: Theme.of(context).accentColor,
            size: 20,
          ),
          SizedBox(
            width: 3,
          ),
          Text(
            AppLocalizations.instance.translate('wallet_connected'),
            style:
                TextStyle(color: Theme.of(context).accentColor, fontSize: 14,letterSpacing: 1.3),
          ),
        ],
      );
    } else if (_connectionState == ElectrumConnectionState.offline) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.offline_bolt_outlined,
            color: Theme.of(context).accentColor,
          ),
          SizedBox(
            width: 3,
          ),
          Text(
            AppLocalizations.instance.translate('wallet_offline'),
            style:
                TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
          ),
        ],
      );
    } else {
      return LoadingIndicator();
    }
  }
}
