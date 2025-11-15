import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';

@lazySingleton
class DioClient {
  final Dio dio;
  final String baseUrl;

  DioClient({required this.baseUrl}) : dio = Dio() {
    // Configuration de base de Dio
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Intercepteurs pour le logging en mode debug
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    // Intercepteur pour la gestion des erreurs
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Vous pouvez ajouter des en-têtes d'authentification ici si nécessaire
          // options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Gestion des erreurs
          Exception exception = _handleDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
              response: error.response,
              type: error.type,
              stackTrace: error.stackTrace,
            ),
          );
        },
      ),
    );
  }

  // Méthodes HTTP de base
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Gestion des erreurs
  Exception _handleDioError(DioException error) {
    // Si l'erreur est déjà une de nos exceptions personnalisées, on la retourne telle quelle
    if (error.error is ServerException ||
        error.error is UnauthorizedException ||
        error.error is ValidationException ||
        error.error is NotFoundException ||
        error.error is TimeoutException) {
      return error.error as Exception;
    }

    // Gestion des erreurs de connexion
    if (error.type == DioExceptionType.connectionError) {
      return NoInternetException(
        'Pas de connexion Internet. Veuillez vérifier votre connexion.',
        error.stackTrace,
      );
    }

    // Gestion des timeouts
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionTimeout) {
      return TimeoutException(
        'La requête a expiré. Veuillez réessayer.',
        error.stackTrace,
      );
    }

    // Gestion des erreurs de réponse du serveur
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (statusCode == 401) {
        return UnauthorizedException(
          data?['message']?.toString() ?? 'Non autorisé',
          error.stackTrace,
        );
      } else if (statusCode == 403) {
        return UnauthorizedException(
          data?['message']?.toString() ?? 'Accès refusé',
          error.stackTrace,
        );
      } else if (statusCode == 404) {
        return NotFoundException(
          data?['message']?.toString() ?? 'Ressource non trouvée',
          error.stackTrace,
        );
      } else if (statusCode != null && statusCode >= 500) {
        return ServerException(
          message: data?['message']?.toString() ?? 'Erreur serveur',
          statusCode: statusCode,
          errorCode: data?['code']?.toString(),
          errors: data?['errors'] is Map<String, dynamic>
              ? data!['errors'] as Map<String, dynamic>
              : null,
          stackTrace: error.stackTrace,
        );
      }
    }

    // Par défaut, on retourne une ServerException générique
    return ServerException(
      message: error.message ?? 'Une erreur inattendue est survenue',
      statusCode: error.response?.statusCode ?? 500,
      stackTrace: error.stackTrace,
    );
  }
}
