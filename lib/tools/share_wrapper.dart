import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'app_localizations.dart';

class ShareWrapper {
  static Future<void> share({
    required BuildContext context,
    required String message,
    bool popNavigator = false,
  }) async {
    if (kIsWeb) {
      await Clipboard.setData(
        ClipboardData(text: message),
      );

      if (popNavigator == true) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate('snack_copied'),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      await Share.share(message);
    }
  }
}
