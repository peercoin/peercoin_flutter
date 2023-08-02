import 'package:hive/hive.dart';
part 'wallet_address.g.dart';

@HiveType(typeId: 2)
class WalletAddress extends HiveObject {
  @HiveField(0)
  final String address;
  @HiveField(1)
  String? addressBookName; //nullable for backward compatability
  @HiveField(2)
  String? status;
  @HiveField(3)
  bool used;
  @HiveField(4)
  bool? isOurs = true; //nullable for backward compatability
  @HiveField(5, defaultValue: '')
  String wif = '';
  @HiveField(6)
  bool? _isChangeAddr = false;
  @HiveField(7, defaultValue: 0)
  int notificationBackendCount = 0;
  @HiveField(8, defaultValue: false)
  bool isWatched = false;

  WalletAddress({
    required this.address,
    required this.addressBookName,
    required this.used,
    required this.status,
    required this.isOurs,
    required this.wif,
  });

  set newStatus(String? newStatus) {
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

  bool get isChangeAddr {
    return _isChangeAddr ?? false;
  }

  set isChangeAddr(bool newChange) {
    _isChangeAddr = newChange;
  }

  set newNotificationBackendCount(int newCount) {
    notificationBackendCount = newCount;
  }
}
