import 'dart:convert';

import 'package:charge_station_finder/infrastructure/dto/userAuthCredential.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/constants.dart';

class ShardPrefHelper {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  static Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await _instance;
    return prefs.setString(key, value);
  }

  static Future<bool> setUser(UserData user) async {
    final SharedPreferences prefs = await _instance;
    return prefs.setString(Constants.User_Key, jsonEncode(user.toJson()));
  }

  static Future<UserData?> getUser() async {
    final SharedPreferences prefs = await _instance;
    var user = prefs.getString(Constants.User_Key);
    if (user == null) {
      return null;
    }
    return UserData.fromJson(jsonDecode(user));
  }

  static Future<bool> clear() async {
    final SharedPreferences prefs = await _instance;
    return prefs.clear();
  }
}
