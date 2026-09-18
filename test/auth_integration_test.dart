import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jastip/models/user_model.dart';
import 'package:jastip/services/auth_service.dart';
import 'package:jastip/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserModel and AuthResponse Tests', () {
    test('UserModel fromJson and toJson should work correctly', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'budi@example.com',
        'phone': '+6281234567890',
        'fullName': 'Budi Santoso',
        'createdAt': '2026-09-14T10:00:00.000Z',
        'updatedAt': '2026-09-14T10:00:00.000Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(user.email, 'budi@example.com');
      expect(user.phone, '+6281234567890');
      expect(user.fullName, 'Budi Santoso');

      final serialized = user.toJson();
      expect(serialized['id'], user.id);
      expect(serialized['email'], user.email);
      expect(serialized['phone'], user.phone);
    });

    test('AuthResponse should parse user and token correctly', () {
      final json = {
        'token': 'mock_jwt_token_12345',
        'user': {
          'id': 'user_1',
          'email': 'siti@example.com',
          'fullName': 'Siti Rahma',
        },
      };

      final authResponse = AuthResponse.fromJson(json);
      expect(authResponse.token, 'mock_jwt_token_12345');
      expect(authResponse.user.email, 'siti@example.com');
      expect(authResponse.user.fullName, 'Siti Rahma');
    });
  });

  group('AuthService Tests', () {
    test('register should return AuthResponse and save session on 201', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/register'));
        final body = jsonDecode(request.body);
        expect(body['email'], 'budi@example.com');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Pendaftaran akun berhasil.',
            'data': {
              'user': {
                'id': 'user_new_id',
                'email': 'budi@example.com',
                'fullName': 'Budi Santoso',
                'phone': '+6281234567890',
              },
              'token': 'jwt_mock_register_token',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final authService = AuthService(client: mockClient);
      final result = await authService.register(
        fullName: 'Budi Santoso',
        email: 'budi@example.com',
        password: 'password123',
        phone: '+6281234567890',
      );

      expect(result.token, 'jwt_mock_register_token');
      expect(result.user.fullName, 'Budi Santoso');

      // Check SharedPreferences
      final savedToken = await authService.getToken();
      expect(savedToken, 'jwt_mock_register_token');
      final savedUser = await authService.getUser();
      expect(savedUser?.email, 'budi@example.com');
    });

    test('login should return AuthResponse and save session on 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/login'));
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Login berhasil.',
            'data': {
              'user': {
                'id': 'user_login_id',
                'email': 'budi@example.com',
                'fullName': 'Budi Santoso',
              },
              'token': 'jwt_mock_login_token',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final authService = AuthService(client: mockClient);
      final result = await authService.login(
        email: 'budi@example.com',
        password: 'password123',
      );

      expect(result.token, 'jwt_mock_login_token');
      expect(result.user.id, 'user_login_id');
    });

    test('login should throw parsed error on 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email atau password tidak sesuai.',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final authService = AuthService(client: mockClient);
      expect(
        () => authService.login(email: 'wrong@example.com', password: 'bad'),
        throwsA(predicate((e) => e.toString().contains('Email atau password tidak sesuai.'))),
      );
    });
  });

  group('AuthProvider Tests', () {
    test('register should auto-login user and set isAuthenticated = true', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'user': {
                'id': 'user_auto_login',
                'email': 'auto@example.com',
                'fullName': 'Auto User',
              },
              'token': 'token_auto',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final authProvider = AuthProvider(authService: AuthService(client: mockClient));
      expect(authProvider.isAuthenticated, false);

      final success = await authProvider.register(
        fullName: 'Auto User',
        email: 'auto@example.com',
        password: 'password123',
      );

      expect(success, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser?.fullName, 'Auto User');
      expect(authProvider.token, 'token_auto');
      expect(authProvider.errorMessage, isNull);
    });

    test('logout should clear currentUser and token', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'user': {
                'id': 'u1',
                'email': 'u1@example.com',
                'fullName': 'User One',
              },
              'token': 'tok1',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final authProvider = AuthProvider(authService: AuthService(client: mockClient));
      await authProvider.login(email: 'u1@example.com', password: 'pw');
      expect(authProvider.isAuthenticated, true);

      await authProvider.logout();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.token, isNull);
    });
  });
}
