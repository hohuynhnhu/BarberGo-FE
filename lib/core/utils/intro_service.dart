import 'package:shared_preferences/shared_preferences.dart';

class IntroService {
  static const String _keyIntroSeen = "intro_seen";

  // Lưu trạng thái đã xem intro
  static Future<void> setIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIntroSeen, true);
  }

  // Kiểm tra xem đã xem intro chưa
  static Future<bool> isIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIntroSeen) ?? false;
  }
}
