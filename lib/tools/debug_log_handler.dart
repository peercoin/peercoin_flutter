import 'package:peercoin/tools/logger_wrapper.dart';

Future<void> initDebugLogHandler() async {
  await LoggerWrapper.ensureInitialized();
}

Future<void> shareDebugLogs() async {
  await LoggerWrapper.shareLogs(
    subject: 'Peercoin Logs',
    text: 'Peercoin debug logs',
  );
}
