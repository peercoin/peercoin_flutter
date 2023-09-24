import 'dart:io';

import 'package:flutter_logs/flutter_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:share_plus/share_plus.dart';

Future<void> initDebugLogHandler() async {
  FlutterLogs.channel.setMethodCallHandler((call) async {
    if (call.method == 'logsExported') {
      var zipName = call.arguments.toString();
      Directory? externalDirectory;

      if (Platform.isIOS) {
        externalDirectory = await getApplicationDocumentsDirectory();
      } else {
        externalDirectory = await getExternalStorageDirectory();
      }

      LoggerWrapper.logInfo(
        'AppSettingsScreen',
        'found',
        'External Storage:$externalDirectory',
      );

      var file = File('${externalDirectory!.path}/$zipName');

      LoggerWrapper.logInfo(
        'AppSettingsScreen',
        'path',
        'Path: \n${file.path}',
      );

      if (file.existsSync()) {
        LoggerWrapper.logInfo(
          'AppSettingsScreen',
          'existsSync',
          'Logs zip found, opening Share overlay',
        );
        await Share.shareXFiles(
          [
            XFile(file.path),
          ],
        );
      } else {
        LoggerWrapper.logError(
          'AppSettingsScreen',
          'existsSync',
          'File not found in storage.',
        );
      }
    }
  });
}
