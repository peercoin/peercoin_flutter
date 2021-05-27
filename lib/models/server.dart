import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'server.g.dart';

@HiveType(typeId: 6)
class Server extends HiveObject {
  @HiveField(0)
  String? _label;

  @HiveField(1)
  String? address;

  @HiveField(2)
  bool? connectable = true;

  @HiveField(3)
  bool? userGenerated;

  @HiveField(4)
  String? _donationAddress;

  @HiveField(5)
  String? _serverBanner;

  @HiveField(6)
  DateTime? _lastConnection;

  @HiveField(7)
  // ignore: prefer_final_fields
  bool? _hidden = false;

  @HiveField(8)
  int? priority;

  Server({
    required this.address,
    required this.priority,
    required this.userGenerated,
  });

  String? get getAddress {
    return address;
  }

  bool? get hidden {
    return _hidden;
  }

  set setPriority(int newValue) {
    priority = newValue;
    save();
  }

  set setConnectable(bool newValue) {
    connectable = newValue;
    save();
  }
}
