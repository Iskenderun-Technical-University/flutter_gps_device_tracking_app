// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferAl {
  static saveStr(String key, String message) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, message);
  }

  static saveInt(String key, int message) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(key, message);
  }

  static saveBl(String key, bool message) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, message);
  }

  static saveList(String key, List<String> message) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setStringList(key, message);
  }

  static readStr(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static readInt(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.getInt(key);
  }

  static readBl(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }

  static readList(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getStringList(key);
  }
}
