class PeriodicReminderItem {
  final String id;
  final String title;
  final String body;
  final String button;
  DateTime _nextNotification = DateTime(1970);
  DateTime _lastNotification = DateTime(1970);

  PeriodicReminderItem({
    required this.id,
    required this.title,
    required this.body,
    required this.button,
  });
}
