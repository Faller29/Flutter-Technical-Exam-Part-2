import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<User?> getCurrentUser();
  Future<Map<String, dynamic>> getProfile();
  Future<void> logout();
  Future<bool> isAuthenticated();
}
