import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'jastip_auth_token';
  static const String _userKey = 'jastip_auth_user';

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // Register user baru
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}');
    final payload = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };
    if (phone != null && phone.trim().isNotEmpty) {
      payload['phone'] = phone.trim();
    }

    try {
      final response = await _client
          .post(
            url,
            headers: ApiConstants.defaultHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(ApiConstants.timeoutDuration);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = responseBody['data'] as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);

        // Simpan token & user data langsung untuk auto-login
        await saveToken(authResponse.token);
        await saveUser(authResponse.user);

        return authResponse;
      } else {
        throw _parseErrorMessage(responseBody, defaultMessage: 'Pendaftaran gagal.');
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server. Pastikan backend aktif di ${ApiConstants.baseUrl}.';
    } on TimeoutException {
      throw 'Koneksi ke server timeout. Silakan periksa koneksi internet Anda.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Terjadi kesalahan sistem: $e';
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    try {
      final response = await _client
          .post(
            url,
            headers: ApiConstants.defaultHeaders(),
            body: jsonEncode(payload),
          )
          .timeout(ApiConstants.timeoutDuration);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final data = responseBody['data'] as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);

        // Simpan token & data pengguna
        await saveToken(authResponse.token);
        await saveUser(authResponse.user);

        return authResponse;
      } else {
        throw _parseErrorMessage(responseBody, defaultMessage: 'Login gagal.');
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server. Pastikan backend aktif di ${ApiConstants.baseUrl}.';
    } on TimeoutException {
      throw 'Koneksi ke server timeout. Silakan periksa koneksi internet Anda.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Terjadi kesalahan sistem: $e';
    }
  }

  // Ambil profil user terkini dari server
  Future<UserModel> getProfile(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileEndpoint}');

    try {
      final response = await _client
          .get(
            url,
            headers: ApiConstants.defaultHeaders(token: token),
          )
          .timeout(ApiConstants.timeoutDuration);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final data = responseBody['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await saveUser(user);
        return user;
      } else {
        throw _parseErrorMessage(responseBody, defaultMessage: 'Gagal mengambil profil.');
      }
    } on SocketException {
      throw 'Tidak dapat terhubung ke server.';
    } on TimeoutException {
      throw 'Koneksi ke server timeout.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Gagal memuat profil: $e';
    }
  }

  // Helper parsing error message dari backend
  String _parseErrorMessage(dynamic body, {required String defaultMessage}) {
    if (body is Map<String, dynamic>) {
      if (body['message'] != null && body['message'].toString().isNotEmpty) {
        final message = body['message'].toString();
        // Jika ada details Zod validation
        if (body['details'] is List && (body['details'] as List).isNotEmpty) {
          final firstDetail = (body['details'] as List).first;
          if (firstDetail is Map && firstDetail['message'] != null) {
            return '$message: ${firstDetail['message']}';
          }
        }
        return message;
      }
    }
    return defaultMessage;
  }

  // --- Session & SharedPreferences Management ---

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        final userJson = jsonDecode(userStr) as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
