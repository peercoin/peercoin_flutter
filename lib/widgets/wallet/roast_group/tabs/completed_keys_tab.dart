import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';

class CompletedKeysTab extends StatelessWidget {
  final Client roastClient;

  const CompletedKeysTab({required this.roastClient, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...roastClient.keys.entries.map(
          (entry) {
            return Card(
              child: ListTile(
                title: Text(
                  entry.value.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                  ),
                ),
                subtitle: Text(
                  entry.value.description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
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
