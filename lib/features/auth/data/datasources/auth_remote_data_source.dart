import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<RegisterResponse> register(RegisterRequest request);
  Future<MeResponse> getCurrentUser(String token);
  Future<void> logout(String token);
  Future<String> refreshToken(String refreshToken);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${dotenv.env['API_URL']}/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data!);
      } else {
        throw ServerException(
          message: response.data?['message'] ?? 'Login failed',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${dotenv.env['API_URL']}/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RegisterResponse.fromJson(response.data!);
      } else {
        throw ServerException(
          message: response.data?['message'] ?? 'Registration failed',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<MeResponse> getCurrentUser(String token) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${dotenv.env['API_URL']}/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return MeResponse.fromJson(response.data!);
      } else {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to get user data',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await dio.post<Map<String, dynamic>>(
        '${dotenv.env['API_URL']}/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      // Even if logout fails on the server, we still want to proceed
      // with local cleanup, so we don't rethrow the error
      if (e.response?.statusCode != 401) {
        throw ServerException.fromDioError(e);
      }
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${dotenv.env['API_URL']}/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return response.data!['accessToken'] as String;
      } else {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to refresh token',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException.fromDioError(e);
    }
  }
}
