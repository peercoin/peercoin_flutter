import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/widgets/buttons.dart';

class OpenRequestTab extends StatelessWidget {
  final Client roastClient;

  const OpenRequestTab({required this.roastClient, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Signatures Requests'), // TODO i18n
        ...roastClient.dkgRequests.map((request) {
          return Column(
            children: [
              Text(
                request.completed.length < request.details.threshold
                    ? 'Pending'
                    : 'Completed',
              ),
              Text('Name: ${request.details.name}'),
              Text(
                'Description: ${request.details.description}',
              ),
              Text('Threshold: ${request.details.threshold}'),
              PeerButton(
                text: 'Ack',
                action: () async {
                  await roastClient.acceptDkg(request.details.name);
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
