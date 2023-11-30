import 'package:flutter/material.dart';

import '../tools/app_localizations.dart';

class SecureStorageFailedScreen extends StatelessWidget {
  const SecureStorageFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Text(
            AppLocalizations.instance.translate(
              'secure_storage_app_bar_title',
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            AppLocalizations.instance.translate(
              'secure_storage_body',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
