import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // Getters
  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty && _currentUser != null;

  // Inisialisasi status autentikasi dari local storage saat aplikasi dibuka
  Future<bool> initializeAuth() async {
    try {
      _token = await _authService.getToken();
      _currentUser = await _authService.getUser();

      // Jika token ada, coba segarkan data profil di latar belakang
      if (_token != null && _token!.isNotEmpty) {
        try {
          final freshUser = await _authService.getProfile(_token!);
          _currentUser = freshUser;
        } catch (_) {
          // Jika gagal segarkan (misal offline), tetap gunakan data user lokal
        }
      }
    } catch (_) {
      _token = null;
      _currentUser = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
    return isAuthenticated;
  }

  // Register pengguna baru (otomatis terhitung login jika berhasil)
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );

      _currentUser = authResponse.user;
      _token = authResponse.token;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login pengguna
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _currentUser = authResponse.user;
      _token = authResponse.token;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout pengguna
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.clearSession();
    } finally {
      _currentUser = null;
      _token = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bersihkan error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
