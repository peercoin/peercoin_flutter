import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:peercoin/providers/app_settings.dart';

class PeriodicReminders {
  static void checkReminder(AppSettings _settings, BuildContext context) async {
    FlutterLogs.logInfo(
      'PeriodicReminders',
      'checkReminder',
      'checking periodic reminders',
    );
    //check if last update was longer than an hour ago
    final oneHourAgo =
        (DateTime.now()).subtract(Duration(minutes: Duration.minutesPerHour));
    if (_settings.latestTickerUpdate.isBefore(oneHourAgo)) {
      FlutterLogs.logInfo(
        'PriceTicker',
        'checkUpdate',
        'reminder scheduled (${_settings.latestTickerUpdate})',
      );

      //show alert

      //schedule next event

    } else {
      FlutterLogs.logInfo(
        'PeriodicReminders',
        'checkReminder',
        'no reminder scheduled. ${_settings.latestTickerUpdate}',
      );
    }
  }
}
