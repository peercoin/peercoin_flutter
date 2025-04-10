import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_home.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ROASTWalletLoginStatus extends StatelessWidget {
  final ROASTLoginStatus status;
  final Function retry;
  final Function openServerEditDialog;

  const ROASTWalletLoginStatus({
    super.key,
    required this.status,
    required this.retry,
    required this.openServerEditDialog,
  });

  void _launchURL(String url) async {
    await canLaunchUrlString(url)
        ? await launchUrlString(
            url,
          )
        : throw 'Could not launch $url';
  }

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
          status == ROASTLoginStatus.noServer
              ? Column(
                  children: [
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'roast_wallet_login_status_no_server_cta',
                      ),
                      action: () => openServerEditDialog(),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      AppLocalizations.instance.translate(
                        'roast_wallet_login_status_no_server_roast_host_nudge',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'roast_wallet_login_status_no_server_roast_host_nudge_cta',
                      ),
                      action: () async => _launchURL(
                        'https://roast.host',
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

// TODO show login failed and cta for no server config -> roast.host
