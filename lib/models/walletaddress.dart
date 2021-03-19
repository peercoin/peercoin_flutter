import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'walletaddress.g.dart';

@HiveType(typeId: 2)
class WalletAddress extends HiveObject {
  @HiveField(0)
  final String address;
  @HiveField(1)
  String addressBookName;
  @HiveField(2)
  String status;
  @HiveField(3)
  bool used;

  WalletAddress({
    @required this.address,
    @required this.addressBookName,
    @required this.used,
    @required this.status,
  });

  set newStatus(String newStatus) {
    status = newStatus;
  }

  set newAddressBookName(String newAdressBookName) {
    addressBookName = newAdressBookName;
  }

  set newUsed(bool newUsed) {
    used = newUsed;
  }
}
