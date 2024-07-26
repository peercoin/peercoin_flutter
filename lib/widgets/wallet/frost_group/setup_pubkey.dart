import 'package:flutter/material.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';

class FrostGroupSetupPubkey extends StatefulWidget {
  const FrostGroupSetupPubkey({super.key});

  @override
  State<FrostGroupSetupPubkey> createState() => _FrostGroupSetupPubkeyState();
}

class _FrostGroupSetupPubkeyState extends State<FrostGroupSetupPubkey> {
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
