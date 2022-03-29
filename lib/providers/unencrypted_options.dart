import 'package:shared_preferences/shared_preferences.dart';

class UnencryptedOptions {
  Future<SharedPreferences> get prefs async {
    return await SharedPreferences.getInstance();
  }
}
