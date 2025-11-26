import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/local_storage_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageDataSource localStorageDataSource;
  final http.Client httpClient;

  AuthRepositoryImpl({
    required this.localStorageDataSource,
    required this.httpClient,
  });

  @override
  Future<User> login(String username, String password) async {
    try {
      final response = await httpClient
          .post(
            Uri.parse(ApiConstants.loginEndpoint),
            headers: ApiConstants.headers,
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final userModel = UserModel.fromJson(data['data']);

          // Save credentials securely
          await localStorageDataSource.saveToken(userModel.token!);
          await localStorageDataSource.saveUserId(userModel.userId);
          await localStorageDataSource.saveUsername(userModel.username);
          await localStorageDataSource.saveName(userModel.name);

          return User(
            userId: userModel.userId,
            username: userModel.username,
            name: userModel.name,
            token: userModel.token,
          );
        } else {
          throw AuthenticationFailure(data['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        throw AuthenticationFailure(data['message'] ?? 'Invalid credentials');
      } else {
        throw ServerFailure('Server error: ${response.statusCode}');
      }
    } on AuthenticationFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw NetworkFailure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await localStorageDataSource.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final userId = await localStorageDataSource.getUserId();
      final username = await localStorageDataSource.getUsername();
      final name = await localStorageDataSource.getName();

      if (userId != null && username != null && name != null) {
        return User(
          userId: userId,
          username: username,
          name: name,
          token: token,
        );
      }
      return null;
    } catch (e) {
      throw CacheFailure('Failed to get user data: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await localStorageDataSource.getToken();

      if (token == null || token.isEmpty) {
        throw AuthenticationFailure('No authentication token found');
      }

      final response = await httpClient
          .get(
            Uri.parse(ApiConstants.profileEndpoint),
            headers: {
              ...ApiConstants.headers,
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data['data'];
        } else {
          throw ServerFailure(data['message'] ?? 'Failed to fetch profile');
        }
      } else if (response.statusCode == 401) {
        await logout();
        throw AuthenticationFailure('Token expired or invalid');
      } else {
        throw ServerFailure('Server error: ${response.statusCode}');
      }
    } on AuthenticationFailure {
      rethrow;
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw NetworkFailure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localStorageDataSource.clearAll();
    } catch (e) {
      throw CacheFailure('Failed to logout: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await localStorageDataSource.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
