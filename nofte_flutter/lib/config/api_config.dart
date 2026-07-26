import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _baseUrlKey = 'api_base_url';
  static const String defaultUrl = 'https://lenders-gnome-guarantees-cultures.trycloudflare.com';
  static String? _cachedBaseUrl;

  static String get baseUrl => _cachedBaseUrl ?? defaultUrl;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedBaseUrl = prefs.getString(_baseUrlKey);
  }

  static Future<void> save(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
    _cachedBaseUrl = url;
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
    _cachedBaseUrl = null;
  }

  static String get displayUrl => _cachedBaseUrl ?? defaultUrl;

  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String scan = '/scan';
  static const String history = '/history';
  static const String inventory = '/inventory';
  static const String inventoryFromScan = '/inventory/from-scan';
}
