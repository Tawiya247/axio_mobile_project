import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  final int statusCode;
  final String? errorCode;
  final Map<String, dynamic>? errors;
  final StackTrace? stackTrace;

  ServerException({
    required this.message,
    required this.statusCode,
    this.errorCode,
    this.errors,
    this.stackTrace,
  });

  factory ServerException.fromDioError(DioException error) {
    try {
      final response = error.response;
      final data = response?.data;

      if (data is Map<String, dynamic>) {
        return ServerException(
          message: data['message'] ?? error.message ?? 'An error occurred',
          statusCode: response?.statusCode ?? 500,
          errorCode: data['code'],
          errors: data['errors'],
          stackTrace: error.stackTrace,
        );
      }

      return ServerException(
        message: error.message ?? 'An error occurred',
        statusCode: response?.statusCode ?? 500,
        stackTrace: error.stackTrace,
      );
    } catch (e, stackTrace) {
      return ServerException(
        message: 'An unexpected error occurred',
        statusCode: 500,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const CacheException(this.message, [this.stackTrace]);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const NetworkException(this.message, [this.stackTrace]);

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const UnauthorizedException([this.message = 'Unauthorized', this.stackTrace]);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;
  final StackTrace? stackTrace;

  const ValidationException({
    required this.message,
    this.errors = const {},
    this.stackTrace,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const NotFoundException([
    this.message = 'Resource not found',
    this.stackTrace,
  ]);

  @override
  String toString() => 'NotFoundException: $message';
}

class NoInternetException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const NoInternetException([
    this.message = 'No internet connection',
    this.stackTrace,
  ]);

  @override
  String toString() => 'NoInternetException: $message';
}

class TimeoutException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const TimeoutException([this.message = 'Request timed out', this.stackTrace]);

  @override
  String toString() => 'TimeoutException: $message';
}

class UnimplementedException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const UnimplementedException([
    this.message = 'Not implemented',
    this.stackTrace,
  ]);

  @override
  String toString() => 'UnimplementedException: $message';
}
