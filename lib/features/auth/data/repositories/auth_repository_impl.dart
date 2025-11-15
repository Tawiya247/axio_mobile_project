import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_models.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<bool> isSignedIn() async {
    final token = await localDataSource.getAccessToken();
    return token != null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null) return null;

      final userData = await remoteDataSource.getCurrentUser(token);
      await localDataSource.saveUserId(userData.user.id);
      await localDataSource.saveUserEmail(userData.user.email);

      return userData.user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<AuthError, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        LoginRequest(email: email, password: password),
      );

      await _saveAuthData(response);

      return Right(response.user);
    } on ServerException catch (e) {
      return Left(
        AuthError(
          message: e.message,
          code: e.errorCode ?? 'server_error',
          stackTrace: e.stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'An unexpected error occurred',
          code: 'unexpected_error',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AuthError, UserEntity>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.register(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          confirmPassword:
              password, // Utiliser le même mot de passe pour la confirmation
        ),
      );

      await _saveAuthData(response);

      return Right(response.user);
    } on ServerException catch (e) {
      return Left(
        AuthError(
          message: e.message,
          code: e.errorCode ?? 'registration_failed',
          stackTrace: e.stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'An unexpected error occurred',
          code: 'unexpected_error',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AuthError, void>> signOut() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token != null) {
        try {
          await remoteDataSource.logout(token);
        } on ServerException {
          // Continue même en cas d'échec de déconnexion côté serveur
        }
      }
      await localDataSource.clearAllData();
      return const Right(null);
    } catch (e) {
      // En cas d'erreur, on efface quand même les données locales
      await localDataSource.clearAllData();
      return const Right(null);
    }
  }

  @override
  Future<Either<AuthError, String>> refreshToken(String refreshToken) async {
    try {
      final newToken = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveAccessToken(newToken);
      return Right(newToken);
    } on ServerException catch (e) {
      return Left(
        AuthError(
          message: e.message,
          code: e.errorCode ?? 'refresh_token_failed',
          stackTrace: e.stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'Failed to refresh token',
          code: 'refresh_token_failed',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AuthError, bool>> checkEmailAvailability(String email) async {
    try {
      // Implémentez la vérification de la disponibilité de l'email
      // Cette méthode dépend de votre API
      return const Right(true);
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'Failed to check email availability',
          code: 'email_check_failed',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AuthError, void>> resetPassword(String email) async {
    try {
      // Implémentez la réinitialisation du mot de passe
      // Cette méthode dépend de votre API
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'Failed to reset password',
          code: 'reset_password_failed',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AuthError, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null) {
        return Left(
          AuthError(
            message: 'Not authenticated',
            code: 'not_authenticated',
            stackTrace: StackTrace.current,
          ),
        );
      }

      // Implémentez la mise à jour du profil
      // Cette méthode dépend de votre API
      final updatedUser = UserEntity(
        id: userId,
        email: await localDataSource.getUserEmail() ?? '',
        name: name,
        photoUrl: photoUrl,
      );

      return Right(updatedUser);
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'Failed to update profile',
          code: 'update_profile_failed',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AuthError, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null) {
        return Left(
          AuthError(
            message: 'Not authenticated',
            code: 'not_authenticated',
            stackTrace: StackTrace.current,
          ),
        );
      }

      // Implémentez le changement de mot de passe
      // Cette méthode dépend de votre API
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'Failed to change password',
          code: 'change_password_failed',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<AuthError, void>> deleteAccount() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token != null) {
        // Implémentez la suppression du compte
        // Cette méthode dépend de votre API
      }
      await localDataSource.clearAllData();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        AuthError(
          message: 'Failed to delete account',
          code: 'delete_account_failed',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _saveAuthData(dynamic response) async {
    if (response is LoginResponse || response is RegisterResponse) {
      await localDataSource.saveAccessToken(response.accessToken);
      if (response.refreshToken != null) {
        await localDataSource.saveRefreshToken(response.refreshToken!);
      }
      await localDataSource.saveUserId(response.user.id);
      await localDataSource.saveUserEmail(response.user.email);
    }
  }
}
