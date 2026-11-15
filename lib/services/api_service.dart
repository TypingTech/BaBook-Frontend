// Simpan sebagai: lib/services/api_service.dart
//
// Sebelumnya jalankan:
//   flutter pub add http flutter_secure_storage

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Hasil dari setiap panggilan API.
class ApiResult {
  final bool success;
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  /// Error per field untuk status 422, contoh: {'email': 'Format email tidak valid'}
  final Map<String, String> errors;

  ApiResult({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors = const {},
  });
}

/// Penyimpanan token login yang aman.
class TokenStorage {
  static const _key = 'auth_token';
  static const _storage = FlutterSecureStorage();

  static Future<void> save(String token) =>
      _storage.write(key: _key, value: token);
  static Future<String?> read() => _storage.read(key: _key);
  static Future<void> clear() => _storage.delete(key: _key);
}

class ApiService {
  // ---------------------------------------------------------------------------
  // BASE URL
  // Untuk HP asli, isi IP laptop kamu, contoh: 'http://192.168.1.10:8080/api'
  // Kosongkan ('') agar dipilih otomatis (emulator Android / web / desktop).
  // ---------------------------------------------------------------------------
  static const String _manualBaseUrl = '';

  static String get baseUrl {
    if (_manualBaseUrl.isNotEmpty) return _manualBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8084/api'; // emulator Android
    }
    return 'http://localhost:8084/api'; // web, Windows, iOS simulator
  }

  static const _timeout = Duration(seconds: 15);

  // ---------------------------------------------------------------------------
  // Fungsi inti: kirim request dan ubah respons jadi ApiResult
  // ---------------------------------------------------------------------------
  static Future<ApiResult> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final http.Response res;
      if (method == 'GET') {
        res = await http.get(uri, headers: headers).timeout(_timeout);
      } else {
        res = await http
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(_timeout);
      }

      Map<String, dynamic> json = {};
      try {
        json = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        // respons bukan JSON valid
      }

      final data = json['data'] as Map<String, dynamic>?;
      final rawErrors = data?['errors'];
      final errors = <String, String>{};
      if (rawErrors is Map) {
        rawErrors.forEach((k, v) => errors[k.toString()] = v.toString());
      }

      return ApiResult(
        success: json['success'] == true,
        statusCode: res.statusCode,
        message:
            (json['message'] as String?) ??
            'Terjadi kesalahan (${res.statusCode})',
        data: data,
        errors: errors,
      );
    } on TimeoutException {
      return ApiResult(
        success: false,
        statusCode: 0,
        message: 'Server tidak merespons. Coba lagi.',
      );
    } catch (_) {
      return ApiResult(
        success: false,
        statusCode: 0,
        message: 'Tidak bisa terhubung ke server. Pastikan backend sudah jalan dan base URL benar.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 1. Register
  // ---------------------------------------------------------------------------
  static Future<ApiResult> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _send(
      'POST',
      '/register.php',
      body: {'name': name, 'email': email, 'password': password},
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Login (token otomatis disimpan jika berhasil)
  // ---------------------------------------------------------------------------
  static Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _send(
      'POST',
      '/login.php',
      body: {'email': email, 'password': password},
    );

    if (result.success) {
      final token = result.data?['token'] as String?;
      if (token != null) await TokenStorage.save(token);
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // 3. Me (cek token & ambil data user)
  // Jika token tidak valid (401), token tersimpan otomatis dihapus.
  // ---------------------------------------------------------------------------
  static Future<ApiResult> me() async {
    final token = await TokenStorage.read();
    if (token == null) {
      return ApiResult(
        success: false,
        statusCode: 401,
        message: 'Token tidak ditemukan',
      );
    }

    final result = await _send('GET', '/me.php', token: token);
    if (result.statusCode == 401) await TokenStorage.clear();
    return result;
  }

  // ---------------------------------------------------------------------------
  // 4. Lupa password (kirim OTP ke email)
  // ---------------------------------------------------------------------------
  static Future<ApiResult> forgotPassword({required String email}) {
    return _send('POST', '/forgot-password.php', body: {'email': email});
  }

  // ---------------------------------------------------------------------------
  // 5. Reset password (pakai OTP). OTP dikirim sebagai String.
  // ---------------------------------------------------------------------------
  static Future<ApiResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final result = await _send(
      'POST',
      '/reset-password.php',
      body: {'email': email, 'otp': otp, 'new_password': newPassword},
    );

    // Backend menghapus semua token lama, jadi token lokal juga dibuang.
    if (result.success) await TokenStorage.clear();
    return result;
  }

  // ---------------------------------------------------------------------------
  // Logout (backend tidak punya endpoint logout, cukup hapus token lokal)
  // ---------------------------------------------------------------------------
  static Future<void> logout() => TokenStorage.clear();
}
