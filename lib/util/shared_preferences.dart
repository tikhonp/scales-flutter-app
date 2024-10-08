import 'package:shared_preferences/shared_preferences.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

class Store {
  static const String agentTokenKey = 'agent_token';
  static const String userSexKey = 'user_sex';
  static const String userAgeKey = 'user_age';
  static const String userHeightKey = 'user_height';

  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> setAgentToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(agentTokenKey, token);
  }

  static Future<String?> getAgentToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(agentTokenKey);
  }

  static Future<void> setUserSex(MiScaleGender sex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userSexKey, sex.index);
  }

  static Future<MiScaleGender?> getUserSex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(userSexKey);
    if (value == null) return null;
    return MiScaleGender.values[value];
  }

  static Future<void> setUserAge(int age) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userAgeKey, age);
  }

  static Future<int?> getUserAge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userAgeKey);
  }

  static Future<void> setUserHeight(double height) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(userHeightKey, height);
  }

  static Future<double?> getUserHeight() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(userHeightKey);
  }
}

