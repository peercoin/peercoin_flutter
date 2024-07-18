import 'package:flutter/material.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class FrostGroupLandingSetup extends StatefulWidget {
  const FrostGroupLandingSetup({super.key});

  @override
  State<FrostGroupLandingSetup> createState() => _FrostGroupLandingSetupState();
}

class _FrostGroupLandingSetupState extends State<FrostGroupLandingSetup> {
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
                    Text('I am the setup page title'),
                    Text(
                        'I am the description of the setup page and will tell you what is going on'),
                    Text(
                        'I am the form Input for the group name (name it what you want)'),
                    Text(
                        'I am the form Input for the group id (carefull, this has to match the other participants)'),
                    Text('I am the server url input'),
                    PeerButton(
                        text: 'Save & Try connection',
                        action: () => print('Save')),
                    Text(
                        'On success you will be taken to the next page where the public keys of the participants will be shown'),
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

// 3. If the configuration is not complete, there will be a configuration page that displays a public key for the participant for them to share.
// 4. On this page a list of other participants is shown with: 1. Name. 2. Identifier and 3. Public key. This list will have a "+" or "Add" button to add a new participant with the ability to edit or remove other participant details.
// 5. There will also be an ID field for the group that can be any string. Should we limit to alphanumeric and possibly underscores?
// 6. After details are updated a new potential GroupConfig will be created and the fingerprint will be shown so that it can be compared against other participant's config to ensure it is the same.
// 7. If a user navigates away from the screen, the current configuration settings will be saved in an incomplete state.
// 7. A "Finish" button will move the state to a completed configuration. An ability to download the configuration details for use on a coordination server will be needed.
// 8. Perhaps the next page should have the options: 1. Connect to server (which will present the full DKG and signing options later). 2. Download configuration (for use on a server). 3. Modify configuration (if configuration is later changed, it goes back to the previous screen).