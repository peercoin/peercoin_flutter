import 'package:hive/hive.dart';
part 'wallet_address.g.dart';

@HiveType(typeId: 2)
class WalletAddress extends HiveObject {
  @HiveField(0)
  final String address;
  @HiveField(1, defaultValue: '')
  String addressBookName;
  @HiveField(2, defaultValue: '')
  String status;
  @HiveField(3)
  bool used;
  @HiveField(4, defaultValue: true)
  bool isOurs = true;
  @HiveField(5, defaultValue: '')
  String wif = '';
  @HiveField(6, defaultValue: false)
  bool isChangeAddr = false;
  @HiveField(7, defaultValue: 0)
  int notificationBackendCount = 0;
  @HiveField(8, defaultValue: false)
  bool isWatched = false;
  @HiveField(9, defaultValue: false)
  bool isLedger = false;

  WalletAddress({
    required this.address,
    required this.addressBookName,
    required this.used,
    required this.status,
    required this.isOurs,
    required this.wif,
  });

  set newStatus(String newStatus) {
    status = newStatus;
  }

  set newAddressBookName(String newAddressBookName) {
    addressBookName = newAddressBookName;
  }

  set newUsed(bool newUsed) {
    used = newUsed;
  }

  set newWif(String newWif) {
    wif = newWif;
  }

  set newNotificationBackendCount(int newCount) {
    notificationBackendCount = newCount;
  }
}
