import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/user_entity.dart';

// Classe pour représenter les erreurs d'authentification
class AuthError extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AuthError({required this.message, this.code, this.stackTrace});

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] ?? 'An error occurred',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    if (code != null) 'code': code,
  };

  @override
  List<Object?> get props => [message, code, stackTrace];

  @override
  String toString() => 'AuthError(message: $message, code: $code)';
}

// Interface du repository d'authentification
abstract class AuthRepository {
  // Vérifie si l'utilisateur est connecté
  Future<bool> isSignedIn();

  // Récupère l'utilisateur actuellement connecté
  Future<UserEntity?> getCurrentUser();

  // Se connecter avec email/mot de passe
  Future<Either<AuthError, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // S'inscrire avec email/mot de passe
  Future<Either<AuthError, UserEntity>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  // Se déconnecter
  Future<Either<AuthError, void>> signOut();

  // Rafraîchir le token
  Future<Either<AuthError, String>> refreshToken(String refreshToken);

  // Vérifier si l'email est disponible
  Future<Either<AuthError, bool>> checkEmailAvailability(String email);

  // Réinitialiser le mot de passe
  Future<Either<AuthError, void>> resetPassword(String email);

  // Mettre à jour le profil utilisateur
  Future<Either<AuthError, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  });

  // Changer le mot de passe
  Future<Either<AuthError, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Supprimer le compte
  Future<Either<AuthError, void>> deleteAccount();
}
