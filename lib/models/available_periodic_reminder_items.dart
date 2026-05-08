import 'periodic_reminder_item.dart';

class AvailablePeriodicReminderItems {
  static final Map<String, PeriodicReminderItem> availableReminderItems = {
    'backup': PeriodicReminderItem(
      id: 'backup',
      title: 'periodic_reminder_backup_title',
      body: 'periodic_reminder_backup_body',
      button: 'jail_dialog_button',
    ),
  };
}
