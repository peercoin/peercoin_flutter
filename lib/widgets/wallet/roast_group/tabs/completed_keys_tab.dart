import 'package:flutter/material.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';

class CompletedKeysTab extends StatelessWidget {
  final Client roastClient;

  const CompletedKeysTab({required this.roastClient, super.key});
  @override
  Widget build(BuildContext context) {
    print(roastClient.keys);
    return Column(
      children: [
        ...roastClient.keys.entries.map(
          (entry) {
            return Text(entry.key.hex);
          },
        ),
      ],
    );
  }
}
