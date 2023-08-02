import 'package:hive/hive.dart';
part 'pending_notifications.g.dart';

@HiveType(typeId: 7)
class PendingNotification extends HiveObject {
  @HiveField(0)
  final String address;
  @HiveField(1)
  final int tx;

  PendingNotification({required this.address, required this.tx});
}
