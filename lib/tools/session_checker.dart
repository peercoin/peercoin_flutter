import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/logout_dialog_dummy.dart'
    if (dart.library.html) '../widgets/logout_dialog.dart';
import 'logger_wrapper.dart';

Future<bool> checkSessionExpired() async {
  if (kIsWeb) {
    final _sessionExpiresAt = int.parse(
        await const FlutterSecureStorage().read(key: 'sessionExpiresAt') ??
            '0');
    if (DateTime.now()
        .isAfter(DateTime.fromMillisecondsSinceEpoch(_sessionExpiresAt))) {
      //session has expired
      await LogoutDialog.clearData();
      LoggerWrapper.logInfo(
        'SessionChecker',
        'checkSessionExpired',
        'session expired, data cleared',
      );
      return true;
    }
    LoggerWrapper.logInfo(
      'SessionChecker',
      'checkSessionExpired',
      'session still valid',
    );
    return false;
  }
  return false;
}
