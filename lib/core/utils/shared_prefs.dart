import 'package:shared_preferences/shared_preferences.dart';

import 'common_imports.dart';

abstract class SharedPrefs {
  static SharedPreferences prefs = sl<SharedPreferences>();

  static Future<void> setUserDetails(String value) async {
    await prefs.setString(SharedPrefsConstant.userDetails, value);
  }

  static String? get getUserDetails {
    return prefs.getString(SharedPrefsConstant.userDetails);
  }

  static Future<bool> remove() async {
    return await prefs.clear();
  }
}
