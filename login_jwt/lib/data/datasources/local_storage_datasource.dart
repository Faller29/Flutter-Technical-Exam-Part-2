import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/storage_constants.dart';

abstract class LocalStorageDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUserId(int userId);
  Future<int?> getUserId();
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
  Future<void> saveName(String name);
  Future<String?> getName();
  Future<void> clearAll();
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  final FlutterSecureStorage secureStorage;

  LocalStorageDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: StorageConstants.tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: StorageConstants.tokenKey);
  }

  @override
  Future<void> saveUserId(int userId) async {
    await secureStorage.write(
      key: StorageConstants.userIdKey,
      value: userId.toString(),
    );
  }

  @override
  Future<int?> getUserId() async {
    final value = await secureStorage.read(key: StorageConstants.userIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  @override
  Future<void> saveUsername(String username) async {
    await secureStorage.write(
      key: StorageConstants.usernameKey,
      value: username,
    );
  }

  @override
  Future<String?> getUsername() async {
    return await secureStorage.read(key: StorageConstants.usernameKey);
  }

  @override
  Future<void> saveName(String name) async {
    await secureStorage.write(key: StorageConstants.nameKey, value: name);
  }

  @override
  Future<String?> getName() async {
    return await secureStorage.read(key: StorageConstants.nameKey);
  }

  @override
  Future<void> clearAll() async {
    await secureStorage.deleteAll();
  }
}
