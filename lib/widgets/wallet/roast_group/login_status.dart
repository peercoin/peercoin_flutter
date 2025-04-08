import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';

class ROASTWalletLoginStatus extends StatelessWidget {
  final ROASTLoginStatus status;
  final Function retry;
  const ROASTWalletLoginStatus({
    super.key,
    required this.status,
    required this.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            status == ROASTLoginStatus.loggedOut
                ? AppLocalizations.instance.translate(
                    'roast_wallet_login_status_logged_out',
                  )
                : status == ROASTLoginStatus.noServer
                    ? AppLocalizations.instance.translate(
                        'roast_wallet_login_status_no_server',
                      )
                    : '',
            minFontSize: 24,
            maxFontSize: 28,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          status == ROASTLoginStatus.loggedOut
              ? PeerButton(text: 'Retry', action: () => retry())
              : const SizedBox(),
        ],
      ),
    );
  }
}

// TODO show login failed and cta for no server config -> roast.host
