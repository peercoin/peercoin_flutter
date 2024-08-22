import 'package:flutter/material.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class FrostGroupLandingConfigured extends StatefulWidget {
  const FrostGroupLandingConfigured({super.key});

  @override
  State<FrostGroupLandingConfigured> createState() =>
      _FrostGroupLandingConfiguredState();
}

class _FrostGroupLandingConfiguredState
    extends State<FrostGroupLandingConfigured> {
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
                        action: () => print('Connect to Server')),
                    const SizedBox(height: 20),
                    PeerButton(
                        text: 'Download configuration',
                        action: () => print('Download configuration')),
                    const SizedBox(height: 20),
                    PeerButton(
                      text: 'Modify configuration',
                      action: () => print('Modify configuration'),
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
