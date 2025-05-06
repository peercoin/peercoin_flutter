import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/screens/wallet/roast/roast_wallet_key_detail.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';

class CompletedKeysTab extends StatelessWidget {
  final Client roastClient;
  final Map<ECPublicKey, Set<int>> derivedKeys;
  final Function(ECPublicKey key, int index) deriveNewAddress;

  const CompletedKeysTab({
    required this.roastClient,
    required this.derivedKeys,
    required this.deriveNewAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print('build');
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
                      arguments: RoastWalletDetailScrenDTO(
                        frostKeyEntry: entry,
                        derivedKeys: derivedKeys[entry.key] ?? {},
                        deriveNewAddress: deriveNewAddress,
                      ),
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
