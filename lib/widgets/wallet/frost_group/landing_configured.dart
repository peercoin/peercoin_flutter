import 'package:flutter/material.dart';
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
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          child: Align(
            child: PeerContainer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Text('hi')],
              ),
            ),
          ),
        ),
      )
    ]);
  }
}
// 1. Connect to server (which will present the full DKG and signing options later). 
// 2. Download configuration (for use on a server). 
// 3. Modify configuration (if configuration is later changed, it goes back to the previous screen).
