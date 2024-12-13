
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<SharedPreferences>? _preferences;

  static Future<SharedPreferences> getPreferences() {
    return _preferences ??= SharedPreferences.getInstance();
  }
}