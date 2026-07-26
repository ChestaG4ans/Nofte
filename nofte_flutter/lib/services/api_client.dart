import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// API Client for making HTTP requests
class ApiClient {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _headers({bool isJson = true}) {
    return {
      if (isJson) HttpHeaders.contentTypeHeader: 'application/json',
      if (_token != null && _token!.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $_token',
    };
  }

  Future<dynamic> get(String path) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers())
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Pastikan WiFi menyala.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server tidak merespons. Periksa URL server di Settings.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server: $e');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Pastikan WiFi menyala.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server tidak merespons. Periksa URL server di Settings.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server: $e');
    }
  }

  Future<dynamic> postBytes(
    String path,
    List<int> bytes, {
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final request = http.Request('POST', Uri.parse('${ApiConfig.baseUrl}$path'));
      request.headers[HttpHeaders.contentTypeHeader] = contentType;
      if (_token != null && _token!.isNotEmpty) {
        request.headers[HttpHeaders.authorizationHeader] = 'Bearer $_token';
      }
      request.bodyBytes = bytes;

      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed).timeout(const Duration(seconds: 60));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Pastikan WiFi menyala.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server tidak merespons. Periksa URL server di Settings.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server: $e');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers())
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak ada koneksi internet. Pastikan WiFi menyala.');
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Server tidak merespons. Periksa URL server di Settings.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal terhubung ke server: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    String message = 'Request gagal (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
    } catch (_) {}

    throw ApiException(message, response.statusCode);
  }
}
