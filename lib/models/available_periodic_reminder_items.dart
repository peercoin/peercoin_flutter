import 'package:peercoin/models/periodic_reminder_item.dart';

class AvailablePeriodicReminderItems {
  final Map<String, PeriodicReminderItem> availableReminderItems = {
    'donate': PeriodicReminderItem(
      id: 'donate',
      title: 'periodic_reminder_donate_title',
      body: 'periodic_reminder_donate_body',
      button: 'jail_dialog_button',
      buttonFunction: () => print('hi'),
    ),
    'backup': PeriodicReminderItem(
      id: 'backup',
      title: 'periodic_reminder_backup_title',
      body: 'periodic_reminder_backup_body',
      button: 'periodic_reminder_backup_button',
      buttonFunction: () => print('hi'),
    )
  };
}
