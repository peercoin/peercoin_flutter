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
  @HiveField(4)
  bool isOurs = true;
  @HiveField(5)
  String wif = '';

  WalletAddress({
    @required this.address,
    @required this.addressBookName,
    @required this.used,
    @required this.status,
    @required this.isOurs,
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
}
