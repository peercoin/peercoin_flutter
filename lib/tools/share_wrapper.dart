import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class ShareWrapper {
  static Future<void> share(String message) async {
    if (kIsWeb) return;
    await Share.share(message);
  }
}
