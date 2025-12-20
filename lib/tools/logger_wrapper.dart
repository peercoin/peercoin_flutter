// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:astute_logger/astute_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class LoggerWrapper {
  static const String debugLogsPreferenceKey = 'debug_logs_enabled';

  static final AstuteLogger _logger = AstuteLogger(
    'Peercoin Flutter',
    enableFileLogging: true,
    fileNamePrefix: 'peercoin_flutter',
  );

  static bool _fileLoggingEnabled = false;
  static Future<void>? _initFuture;

  static bool get loggingEnabled => _fileLoggingEnabled;

  static Future<void> setLoggingEnabled(bool enabled) async {
    final wasEnabled = _fileLoggingEnabled;
    _fileLoggingEnabled = enabled;

    if (_fileLoggingEnabled) {
      final loggingStartTime = !wasEnabled ? DateTime.now() : null;
      await ensureInitialized();
      if (loggingStartTime != null) {
        await _logLoggingEnabledInfo(loggingStartTime);
      }
    }
  }

  static Future<void> ensureInitialized() {
    if (!_fileLoggingEnabled) return Future.value();

    _initFuture ??= _initialize();
    return _initFuture!;
  }

  static Future<void> _initialize() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    if (!_fileLoggingEnabled) {
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final logsDir = '${dir.path}${Platform.pathSeparator}MyLogs';
    await _logger.initFileLogging(directoryPath: logsDir);
  }

  static Future<void> _logLoggingEnabledInfo(DateTime loggingStartTime) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final startTime = loggingStartTime.toIso8601String();
    final message =
        'App version ${packageInfo.version} build ${packageInfo.buildNumber}. '
        'Start time: $startTime';

    _log(
      LogLevel.info,
      'LoggerWrapper',
      'LoggingEnabled',
      message,
    );
  }

  static Future<void> _logToFileInRelease(
    LogLevel level,
    String tag,
    String message,
  ) async {
    await ensureInitialized();
    final logFile = _logger.logFile;
    if (logFile == null) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelLabel = _labelForLevel(level);
    await logFile.writeAsString(
      '[$timestamp] [$levelLabel] [$tag] $message\n',
      mode: FileMode.append,
      flush: true,
    );
  }

  static void _log(
    LogLevel level,
    String tag,
    String subTag,
    String logMessage,
  ) {
    if (kIsWeb) {
      print('$tag $subTag $logMessage');
      return;
    }
    if (!_fileLoggingEnabled ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    // kick off async initialization without blocking callers
    ensureInitialized();

    final message = '[$subTag] $logMessage';

    if (kReleaseMode) {
      unawaited(_logToFileInRelease(level, tag, message));
      return;
    }

    switch (level) {
      case LogLevel.info:
        _logger.info(message, tag: tag);
        break;
      case LogLevel.warning:
        _logger.warning(message, tag: tag);
        break;
      case LogLevel.error:
        _logger.error(message, tag: tag);
        break;
      default:
        _logger.info(message, tag: tag);
    }
  }

  static String _labelForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.off:
        return 'OFF';
    }
  }

  static void logInfo(String tag, String subTag, String logMessage) {
    _log(LogLevel.info, tag, subTag, logMessage);
  }

  static void logError(String tag, String subTag, String logMessage) {
    _log(LogLevel.error, tag, subTag, logMessage);
  }

  static void logWarn(String tag, String subTag, String logMessage) {
    _log(LogLevel.warning, tag, subTag, logMessage);
  }

  static Future<void> shareLogs({
    String? subject,
    String? text,
  }) async {
    if (kIsWeb ||
        Platform.environment.containsKey('FLUTTER_TEST') ||
        !_fileLoggingEnabled) {
      return;
    }

    await ensureInitialized();
    final shared = await _logger.shareLogFile(
      subject: subject ?? 'Peercoin Logs',
      text: text ?? 'Attached logs from Peercoin',
    );

    if (!shared) {
      _logger.warning(
        '[shareLogs] Sharing logs was unavailable or canceled.',
        tag: 'LoggerWrapper',
      );
    }
  }
}
