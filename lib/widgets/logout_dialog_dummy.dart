import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  static Future<void> clearData() {
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/* This dummy is required to prevent build time errors since dart:html is not availble on native devices */