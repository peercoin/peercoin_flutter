class PeriodicReminderItem {
  final String id;
  final String title;
  final String body;
  final String button;
  final Function buttonFunction;
  DateTime nextNotification = DateTime(1970);
  DateTime lastNotification = DateTime(1970);

  PeriodicReminderItem({
    required this.id,
    required this.title,
    required this.body,
    required this.button,
    required this.buttonFunction,
  });
}
