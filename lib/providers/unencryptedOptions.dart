import 'package:shared_preferences/shared_preferences.dart';

class UnencryptedOptions {
  Future<SharedPreferences> get prefs async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> get setupFinished async {
    var instance = await prefs;
    return instance.getBool("setupFinished");
  }
}
