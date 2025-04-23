import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';

class CompletedKeysTab extends StatelessWidget {
  final Client roastClient;

  const CompletedKeysTab({required this.roastClient, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.instance.translate(
            'roast_wallet_completed_keys',
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 30),
        ...roastClient.keys.entries.map(
          (entry) {
            return Card(
              child: ListTile(
                title: Text(
                  entry.value.name,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  entry.value.description.isNotEmpty
                      ? entry.value.description
                      : AppLocalizations.instance.translate(
                          'roast_wallet_open_requests_description_empty',
                        ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                  ),
                ),
                trailing: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.roastWalletKeyDetail,
                      arguments: {
                        'frostKeyEntry': entry,
                      },
                    );
                  },
                  child: Icon(
                    Icons.open_in_new,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
