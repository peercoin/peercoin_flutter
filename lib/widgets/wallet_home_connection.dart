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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/ppc-icon-white-256.png',
            width: 40,
          ),
          SizedBox(height: 10,),
          Text(
            AppLocalizations.instance.translate('wallet_connected'),
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontSize: 16,
              letterSpacing: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (_connectionState == ElectrumConnectionState.offline) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/ppc-icon-white-256.png',
            width: 40,
          ),
          SizedBox(height: 10,),
          Text(
            AppLocalizations.instance.translate('wallet_offline'),
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontSize: 16,
              letterSpacing: 1.4,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/ppc-icon-white-256.png',
            width: 40,
          ),
          SizedBox(height: 10,),
          LoadingIndicator(),
        ],
      );
    }
  }
}
