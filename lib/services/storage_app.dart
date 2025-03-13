import 'package:shared_preferences/shared_preferences.dart';

class StorageApp {
  static const String _sessionKey = 'session';

  static StorageApp? _instance;
  SharedPreferences? _prefs;

  factory StorageApp() {
    _instance ??= StorageApp._();
    return _instance!;
  }

  StorageApp._();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveSession(String session) async {
    await _prefs!.setString(_sessionKey, session);
  }

  String? getSession() {
    return _prefs!.getString(_sessionKey);
  }

  Future<void> clearSession() async {
    await _prefs!.remove(_sessionKey);
  }
}
