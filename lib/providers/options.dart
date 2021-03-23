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

  Future<bool> containsKey(String key) async {
    var instance = await prefs;
    return instance.containsKey(key);
  }

  Future<bool> get allowMetaData async {
    return getBooleanValue("allowMetaData");
  }

  setAllowMetaData(bool value) async {
    setBooleanValue("allowMetaData", value);
  }

  setBooleanValue(String key, bool value) async {
    var instance = await prefs;
    instance.setBool(key, value);
  }

  Future<bool> getBooleanValue(String key) async {
    var instance = await prefs;
    return instance.getBool(key) ?? false;
  }
}
