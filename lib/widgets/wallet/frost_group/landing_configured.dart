import 'package:flutter/material.dart';
import 'package:peercoin/models/hive/frost_group.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:share_plus/share_plus.dart';

class FrostGroupLandingConfigured extends StatefulWidget {
  final FrostGroup frostGroup;
  const FrostGroupLandingConfigured({required this.frostGroup, super.key});

  @override
  State<FrostGroupLandingConfigured> createState() =>
      _FrostGroupLandingConfiguredState();
}

class _FrostGroupLandingConfiguredState
    extends State<FrostGroupLandingConfigured> {
  void _tryConnectToServer() {
    print('Try connect to server');
  }

  void _modifyConfiguration() {
    print('Modify configuration');
  }

  void _exportConfiguration() {
    print('Export configuration');
    Share.share(widget.frostGroup.clientConfig!.group
        .toString()); //TODO check if this makes sense or we need to export to some binary format? yaml?
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
                      text: 'Connect to server',
                      action: () => _tryConnectToServer(),
                    ),
                    const SizedBox(height: 20),
                    PeerButton(
                      text: 'Download configuration',
                      action: () => _exportConfiguration(),
                    ),
                    const SizedBox(height: 20),
                    PeerButton(
                      text: 'Modify configuration',
                      action: () => _modifyConfiguration(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
// 1. Connect to server (which will present the full DKG and signing options later). 
// 2. Download configuration (for use on a server). 
// 3. Modify configuration (if configuration is later changed, it goes back to the previous screen).
