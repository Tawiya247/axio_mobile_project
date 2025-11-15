import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  // JWT Token
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<void> deleteAccessToken();

  // Refresh Token
  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<void> deleteRefreshToken();

  // User ID
  Future<String?> getUserId();
  Future<void> saveUserId(String userId);
  Future<void> deleteUserId();

  // User Email
  Future<String?> getUserEmail();
  Future<void> saveUserEmail(String email);
  Future<void> deleteUserEmail();

  // Clear all auth data
  Future<void> clearAllData();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  // JWT Token
  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }

  // Refresh Token
  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // User ID
  @override
  Future<String?> getUserId() async {
    return _sharedPreferences.getString(_userIdKey);
  }

  @override
  Future<void> saveUserId(String userId) async {
    await _sharedPreferences.setString(_userIdKey, userId);
  }

  @override
  Future<void> deleteUserId() async {
    await _sharedPreferences.remove(_userIdKey);
  }

  // User Email
  @override
  Future<String?> getUserEmail() async {
    return _sharedPreferences.getString(_userEmailKey);
  }

  @override
  Future<void> saveUserEmail(String email) async {
    await _sharedPreferences.setString(_userEmailKey, email);
  }

  @override
  Future<void> deleteUserEmail() async {
    await _sharedPreferences.remove(_userEmailKey);
  }

  // Clear all auth data
  @override
  Future<void> clearAllData() async {
    await Future.wait([
      deleteAccessToken(),
      deleteRefreshToken(),
      deleteUserId(),
      deleteUserEmail(),
    ]);
  }
}
