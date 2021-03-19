import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Options with ChangeNotifier {
  Future<SharedPreferences> get prefs async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> get setupFinished async {
    var instance = await prefs;
    return instance.getBool("setupFinished");
  }
}
