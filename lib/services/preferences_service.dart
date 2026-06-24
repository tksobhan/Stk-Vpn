import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesService {
  static const String _keyPassword = 'admin_password';
  static const String _keyLanguage = 'language';
  static const String _keyFirstRun = 'first_run';

  static final _storage = const FlutterSecureStorage();

  // ذخیره رمز عبور
  static Future<void> savePassword(String password) async {
    await _storage.write(key: _keyPassword, value: password);
  }

  // دریافت رمز عبور (پیش‌فرض: 1234)
  static Future<String> getPassword() async {
    final password = await _storage.read(key: _keyPassword);
    return password ?? '1234';
  }

  // ذخیره زبان (fa/en)
  static Future<void> saveLanguage(String lang) async {
    await _storage.write(key: _keyLanguage, value: lang);
  }

  // دریافت زبان (پیش‌فرض: fa)
  static Future<String> getLanguage() async {
    final lang = await _storage.read(key: _keyLanguage);
    return lang ?? 'fa';
  }

  // تغییر رمز عبور (با تأیید رمز قبلی)
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    final current = await getPassword();
    if (current != oldPassword) return false;
    await savePassword(newPassword);
    return true;
  }
}
