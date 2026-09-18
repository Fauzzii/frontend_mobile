import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  // Ubah ipAddress di sini jika menjalankan aplikasi di Real Device fisik dalam 1 jaringan Wi-Fi lokal
  // Contoh: 'http://192.168.1.10:5000/api'
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    // Android Emulator menggunakan 10.0.2.2 untuk mengakses localhost mesin pengembang
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    }

    // iOS Simulator, Windows Desktop, macOS, Linux
    return 'http://localhost:5000/api';
  }

  // Endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/users/profile';
  static const String changePasswordEndpoint = '/users/change-password';

  // Request timeout
  static const Duration timeoutDuration = Duration(seconds: 15);

  // Headers helper
  static Map<String, String> defaultHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
