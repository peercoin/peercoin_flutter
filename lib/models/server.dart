import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// part 'server.g.dart';

@HiveType(typeId: 6)
class Server extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  InternetAddress address;

  @HiveField(2)
  bool blocked = false;

  @HiveField(3)
  String source;
  //TODO enum? - seed, servers peers, user

  @HiveField(4)
  String donationAddress;

  @HiveField(5)
  String serverBanner;

  @HiveField(6)
  DateTime lastConnection;

  Server({@required this.name, @required this.address, @required this.source});
}
