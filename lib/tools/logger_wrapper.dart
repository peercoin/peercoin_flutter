// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LoggerWrapper {
  static final MemoryOutput _memoryOutput = MemoryOutput(
    bufferSize: 3000,
    secondOutput: ConsoleOutput(),
  );

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: _memoryOutput,
  );

  static bool _initialized = false;

  static Future<void> initLogs() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    if (_initialized) return;

    await _logger.init;
    _initialized = true;
  }

  static Future<void> exportLogs() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;

    try {
      final lines = <String>[];
      for (final event in _memoryOutput.buffer) {
        lines.addAll(event.lines);
      }

      if (lines.isEmpty) {
        _logger.w('[LoggerWrapper][exportLogs] No logs available to export.');
        return;
      }

      final tempDirectory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${tempDirectory.path}/peercoin_logs_$timestamp.txt');

      await file.writeAsString('${lines.join('\n')}\n');
      await Share.shareXFiles(
        [
          XFile(file.path),
        ],
      );
    } catch (e, stackTrace) {
      _logger.e(
        '[LoggerWrapper][exportLogs] Failed to export logs.',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static void logInfo(String tag, String subTag, String logMessage) {
    _log(
      Level.info,
      tag,
      subTag,
      logMessage,
    );
  }

  static void logError(String tag, String subTag, String logMessage) {
    _log(
      Level.error,
      tag,
      subTag,
      logMessage,
    );
  }

  static void logWarn(String tag, String subTag, String logMessage) {
    _log(
      Level.warning,
      tag,
      subTag,
      logMessage,
    );
  }

  static void _log(Level level, String tag, String subTag, String message) {
    if (kIsWeb) {
      print('[$tag][$subTag] $message');
      return;
    }
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    _logger.log(
      level,
      '[$tag][$subTag] $message',
    );
  }
}
