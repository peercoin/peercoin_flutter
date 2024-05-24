import 'package:flutter/material.dart';

import '../../providers/connection_provider.dart';
import '/../tools/app_localizations.dart';
import '/../widgets/loading_indicator.dart';

class WalletHomeConnection extends StatelessWidget {
  final BackendConnectionState _connectionState;
  const WalletHomeConnection(this._connectionState, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (_connectionState == BackendConnectionState.connected) {
      widget = Text(
        AppLocalizations.instance.translate('wallet_connected'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          letterSpacing: 1.4,
          fontSize: 16,
        ),
      );
    } else if (_connectionState == BackendConnectionState.offline) {
      widget = Text(
        AppLocalizations.instance.translate('wallet_offline'),
        style: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          fontSize: 16,
          letterSpacing: 1.4,
        ),
      );
    } else {
      widget = const SizedBox(width: 88, child: LoadingIndicator());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icon/ppc-icon-white-256.png',
          width: 20,
        ),
        const SizedBox(
          width: 10,
        ),
        widget,
      ],
    );
  }
}
