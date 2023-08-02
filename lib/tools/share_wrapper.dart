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
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(
        ClipboardData(text: message),
      );

      if (popNavigator == true) navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.instance.translate('snack_copied'),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        message,
        sharePositionOrigin: Rect.fromCenter(
          center: box!.size.center(box.localToGlobal(Offset.zero)),
          width: 100,
          height: 100,
        ),
      );
    }
  }
}
