
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<SharedPreferences>? preferences;

  static Future<SharedPreferences> getPreferences() {
    return preferences ??= SharedPreferences.getInstance();
  }
}