import 'package:flutter/foundation.dart';
import 'package:flutter_logs/flutter_logs.dart';

class LoggerWrapper {
  static void logInfo(String tag, String subTag, String logMessage) {
    if (kIsWeb) {
      print('$tag $subTag $logMessage');
      return;
    }

    FlutterLogs.logInfo(
      tag,
      subTag,
      logMessage,
    );
  }

  static void logError(String tag, String subTag, String logMessage) {
    if (kIsWeb) {
      print('$tag $subTag $logMessage');
      return;
    }

    FlutterLogs.logError(
      tag,
      subTag,
      logMessage,
    );
  }

  static void logWarn(String tag, String subTag, String logMessage) {
    if (kIsWeb) {
      print('$tag $subTag $logMessage');
      return;
    }

    FlutterLogs.logWarn(
      tag,
      subTag,
      logMessage,
    );
  }
}
