import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Service for authentication operations
class AuthService {
  static const String _tokenKey = 'nofte_access_token';
  final ApiClient _api;

  AuthService(this._api);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _api.setToken(token);
  }

  Future<void> restoreToken() async {
    final token = await getToken();
    if (token != null) {
      _api.setToken(token);
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _api.clearToken();
  }

  Future<User> login({required String email, required String password}) async {
    final data = await _api.post(ApiConfig.authLogin, {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    final token = data['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw ApiException('Token tidak ditemukan');
    }

    await saveToken(token);
    return me();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _api.post(ApiConfig.authRegister, {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<User> me() async {
    final data = await _api.get(ApiConfig.authMe) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<void> logout() async {
    await clearToken();
  }
}
