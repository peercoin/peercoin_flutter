import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:frost_noosphere/frost_noosphere.dart' as frost;
import 'package:grpc/grpc.dart';
import 'package:peercoin/models/hive/roast_client.dart';
import 'package:peercoin/models/roast_storage.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:share_plus/share_plus.dart';

class ROASTGroupLandingConfigured extends StatefulWidget {
  final ROASTClient roastClient;
  const ROASTGroupLandingConfigured({required this.roastClient, super.key});

  @override
  State<ROASTGroupLandingConfigured> createState() =>
      _ROASTGroupLandingConfiguredState();
}

class _ROASTGroupLandingConfiguredState
    extends State<ROASTGroupLandingConfigured> {
  void _tryLogin() {
    final uri = Uri.parse(widget.roastClient.serverUrl);
    print(bytesToHex(widget.roastClient.clientConfig!.group.toBytes()));
    print(widget.roastClient.clientConfig!.group.yaml);

    frost.Client.login(
      config: widget.roastClient.clientConfig!,
      api: frost.GrpcClientApi(
        ClientChannel(
          uri.host,
          port: uri.port,
          options: ChannelOptions(
            credentials: ChannelCredentials.insecure(), // TODO remove
          ),
        ),
      ),
      store: ROASTStorage(widget.roastClient),
      getPrivateKey: (_) async => widget.roastClient.ourKey,
    );
  }

  Future<void> _serverURLEditDialog() async {
    var textFieldController = TextEditingController();
    textFieldController.text = widget.roastClient.serverUrl;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate(
              'roast_landing_configured_edit_server_url_title',
            ),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: textFieldController,
            decoration: InputDecoration(
              hintText: AppLocalizations.instance.translate(
                'roast_landing_configured_edit_server_url_placeholder',
              ),
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
                widget.roastClient.setServerUrl = textFieldController.text;
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

  void _exportConfiguration() {
    LoggerWrapper.logInfo(
      'ROASTGroupLandingConfigured',
      '_exportConfiguration',
      'Exporting server configuration',
    );

    if (widget.roastClient.clientConfig == null ||
        widget.roastClient.clientConfig?.group == null) {
      return;
    }

    Share.share(
      frost.ServerConfig(group: widget.roastClient.clientConfig!.group).yaml,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              child: PeerContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PeerButton(
                      text: 'Login to server',
                      action: () => _tryLogin(),
                    ),
                    const SizedBox(height: 20),
                    // TODO login to server
                    // TODO present DKG with details and stage (round1, round2)
                    // TODO roast key with details has to be stored (ClientStorageInterface and its methods has to be implemented)
                    PeerButton(
                      text: 'Export server configuration',
                      action: () => _exportConfiguration(),
                    ),
                    const SizedBox(height: 20),
                    PeerButton(
                      text: 'Modify server URL',
                      action: () => _serverURLEditDialog(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// TODO i18n
// 1. Connect to server (which will present the full DKG and signing options later). mock for now.
// 2. Download configuration (for use on a server).
// 3. Modify configuration (if configuration is later changed, it goes back to the previous screen). Only allow server url + nick names for participants to be changed.
