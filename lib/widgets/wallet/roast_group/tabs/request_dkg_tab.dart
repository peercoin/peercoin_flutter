import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/widgets/buttons.dart';

class RequestDKGTab extends StatelessWidget {
  final Client roastClient;

  const RequestDKGTab({required this.roastClient, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PeerButton(
          text: 'Request DKG',
          action: () async {
            await roastClient.requestDkg(
              NewDkgDetails(
                name: 'test${DateTime.now()}',
                description: 'test',
                threshold: 2,
                expiry: Expiry(const Duration(days: 1)),
              ),
            );
          },
        ),
      ],
    );
  }
}
