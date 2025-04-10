import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/service_container.dart';

class OpenRequestTab extends StatelessWidget {
  final Client roastClient;
  final Function forceRender;

  const OpenRequestTab({
    required this.roastClient,
    required this.forceRender,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            Align(
              child: PeerContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    roastClient.dkgRequests.isEmpty
                        ? Text(
                            AppLocalizations.instance.translate(
                              'roast_wallet_open_requests_empty',
                            ),
                          )
                        : const SizedBox(),
                    ...roastClient.dkgRequests.asMap().entries.map((entry) {
                      final index = entry.key;
                      final request = entry.value;
                      return Column(
                        children: [
                          index > 0 ? const Divider() : const SizedBox(),
                          Text('Name: ${request.details.name}'),
                          Text(
                            'Description: ${request.details.description}',
                          ),
                          Text('Threshold: ${request.details.threshold}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () async {
                                  await roastClient
                                      .acceptDkg(request.details.name);
                                  forceRender();
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () async {
                                  await roastClient
                                      .acceptDkg(request.details.name);
                                  forceRender();
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
