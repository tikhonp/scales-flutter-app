import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static const String apiTokenKey = 'api_token';
  static const String latestFetchedRecordTimeStampKey =
      'latest_fetched_record_timestamp';

  static Future<void> setApiToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(apiTokenKey, token);
  }

  static Future<String?> getApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(apiTokenKey);
  }

  static Future<void> setLatestFetchedRecordTimeStamp(int timestamp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(latestFetchedRecordTimeStampKey, timestamp);
  }

  static Future<int?> getLatestFetchedRecordTimeStamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(latestFetchedRecordTimeStampKey);
  }
}

