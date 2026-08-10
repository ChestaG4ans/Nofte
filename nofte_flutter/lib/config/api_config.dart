import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _baseUrlKey = 'api_base_url';

  // Untuk development local, pakai localhost
  // Kalau dari HP/emulator beda jaringan, pakai IP: http://192.168.0.103:8000
  static const String defaultUrl = 'http://localhost:8000';

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

  // Gemini API Config
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String defaultGeminiKey = 'AIzaSyDemoKeyForNoFTeApp';

  static String? _cachedGeminiApiKey;

  static String get geminiApiKey => _cachedGeminiApiKey ?? defaultGeminiKey;

  static Future<void> loadGeminiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedGeminiApiKey = prefs.getString(_geminiApiKeyKey);
  }

  static Future<void> saveGeminiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, key);
    _cachedGeminiApiKey = key;
  }

  static String get geminiBaseUrl => 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
}
