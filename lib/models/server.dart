import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'server.g.dart';

@HiveType(typeId: 6)
class Server extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  InternetAddress address;

  @HiveField(2)
  bool connectable = true;

  @HiveField(3)
  bool userGenerated;

  @HiveField(4)
  String donationAddress;

  @HiveField(5)
  String serverBanner;

  @HiveField(6)
  DateTime lastConnection;

  Server({
    @required this.address,
  });
}
