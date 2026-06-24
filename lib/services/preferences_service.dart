import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyPassword = 'admin_password';
  static const String _keyLanguage = 'language';

  // ذخیره رمز عبور
  static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPassword, password);
  }

  // دریافت رمز عبور (پیش‌فرض: 1234)
  static Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword) ?? '1234';
  }

  // ذخیره زبان (fa/en)
  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  // دریافت زبان (پیش‌فرض: fa)
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'fa';
  }

  // تغییر رمز عبور (با تأیید رمز قبلی)
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    final current = await getPassword();
    if (current != oldPassword) return false;
    await savePassword(newPassword);
    return true;
  }
}
