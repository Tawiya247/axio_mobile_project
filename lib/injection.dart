// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_print
// ignore_for_file: depend_on_referenced_packages

import 'package:axio_mobile_project/core/network/dio_client.dart';
import 'package:axio_mobile_project/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:axio_mobile_project/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:axio_mobile_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:axio_mobile_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:axio_mobile_project/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:axio_mobile_project/features/auth/domain/usecases/sign_up_with_email_and_password.dart';
import 'package:axio_mobile_project/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:axio_mobile_project/features/expenses/domain/repositories/expense_repository.dart';
import 'package:axio_mobile_project/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:axio_mobile_project/features/settings/domain/repositories/settings_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async {
  // Initialisation des dépendances synchrones
  _registerCoreDependencies();
  _registerAuthDependencies();

  // Initialisation des dépendances asynchrones
  await _registerAsyncDependencies();

  // Génération de l'injection
  await $initGetIt(getIt);
}

void _registerCoreDependencies() {
  // Client HTTP
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: const String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:3000/api',
      ),
    ),
  );

  // Expense Repository
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(getIt<DioClient>()),
  );

  // Settings Repository
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(),
  );

  // Stockage sécurisé
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
}

void _registerAuthDependencies() {
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt<FlutterSecureStorage>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => SignInWithEmailAndPassword(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
    () => SignUpWithEmailAndPassword(getIt<AuthRepository>()),
  );
}

Future<void> _registerAsyncDependencies() async {
  // Initialisation de SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}
