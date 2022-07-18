import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/available_periodic_reminder_items.dart';
import '../models/periodic_reminder_item.dart';
import '../providers/app_settings.dart';
import 'app_localizations.dart';
import 'logger_wrapper.dart';

class PeriodicReminders {
  static Future<void> displayReminder(
      BuildContext ctx, PeriodicReminderItem reminderItem) async {
    //show alert
    await showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate(reminderItem.title),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.instance.translate(reminderItem.body),
          ),
          actions: <Widget>[
            if (reminderItem.id == 'donate')
              TextButton(
                //TODO add donate now deep link
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  var url = 'https://ppc.lol/fndtn/';
                  await canLaunchUrlString(url)
                      ? await launchUrlString(url)
                      : throw 'Could not launch $url';
                  navigator.pop();
                },
                child: Text(
                  AppLocalizations.instance.translate(reminderItem.button),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );

    LoggerWrapper.logInfo(
      'PriceTicker',
      'displayReminder',
      '${reminderItem.id} displayed})',
    );
  }

  static void scheduleNextEvent(String name, AppSettings settings) {
    final newDate = (DateTime.now()).add(
      Duration(
        days: 30 + Random().nextInt(45 - 30),
      ),
    ); //next notification in 30 to 45 days

    LoggerWrapper.logInfo(
      'PriceTicker',
      'displayReminder',
      '$name next event scheduled for $newDate})',
    );

    final timeMap = settings.periodicReminterItemsNextView;
    timeMap[name] = newDate;
    settings.setPeriodicReminterItemsNextView(timeMap);
  }

  static Future<void> checkReminder(
      AppSettings settings, BuildContext context) async {
    LoggerWrapper.logInfo(
      'PeriodicReminders',
      'checkReminder',
      'checking periodic reminders',
    );

    //get map of next reminders
    final nextReminders = settings.periodicReminterItemsNextView;

    var messageFired =
        false; //only fire one reminder per startup - prevent double notification

    //loop through available reminders

    for (var entry
        in AvailablePeriodicReminderItems.availableReminderItems.entries) {
      final name = entry.key;
      final item = entry.value;
      var shouldDisplayReminder = false;

      if (!messageFired) {
        if (nextReminders.containsKey(name)) {
          //value has been initialized
          //check if alert is due
          if (DateTime.now().isAfter(nextReminders[name]!)) {
            LoggerWrapper.logInfo(
              'PriceTicker',
              'checkUpdate',
              'reminder $name scheduled})',
            );

            shouldDisplayReminder = true;
          }
        } else {
          //value has not been initialized yet - show reminder now
          LoggerWrapper.logInfo(
            'PriceTicker',
            'checkUpdate',
            'reminder $name is not initialized})',
          );
          shouldDisplayReminder = true;
        }
        if (shouldDisplayReminder) {
          await displayReminder(context, item);
          scheduleNextEvent(item.id, settings);
          messageFired = true;
        }
      }
    }
    //loop over - no message fired?
    if (!messageFired) {
      LoggerWrapper.logInfo(
        'PeriodicReminders',
        'checkReminder',
        'no reminder scheduled.',
      );
    }
  }
}
