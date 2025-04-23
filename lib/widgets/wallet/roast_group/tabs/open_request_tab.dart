import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';

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
                    final request = entry.value;
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Column(
                          children: [
                            Text(
                              request.details.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () async {
                                    await roastClient
                                        .acceptDkg(request.details.name);
                                    forceRender();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
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
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
