import 'package:equatable/equatable.dart';

class AuthError extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AuthError({required this.message, this.code, this.stackTrace});

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      message: json['message'] ?? 'Une erreur est survenue',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    if (code != null) 'code': code,
  };

  @override
  String toString() => 'AuthError(message: $message, code: $code)';

  @override
  List<Object?> get props => [message, code];

  // Erreurs courantes
  static const AuthError invalidEmail = AuthError(
    message: 'Adresse email invalide',
    code: 'invalid-email',
  );

  static const AuthError userDisabled = AuthError(
    message: 'Ce compte a été désactivé',
    code: 'user-disabled',
  );

  static const AuthError userNotFound = AuthError(
    message: 'Aucun compte trouvé avec cette adresse email',
    code: 'user-not-found',
  );

  static const AuthError wrongPassword = AuthError(
    message: 'Mot de passe incorrect',
    code: 'wrong-password',
  );

  static const AuthError emailAlreadyInUse = AuthError(
    message: 'Cette adresse email est déjà utilisée',
    code: 'email-already-in-use',
  );

  static const AuthError operationNotAllowed = AuthError(
    message: 'Cette opération n\'est pas autorisée',
    code: 'operation-not-allowed',
  );

  static const AuthError weakPassword = AuthError(
    message: 'Le mot de passe est trop faible',
    code: 'weak-password',
  );

  static const AuthError networkRequestFailed = AuthError(
    message: 'Erreur de connexion réseau',
    code: 'network-request-failed',
  );

  static const AuthError unknown = AuthError(
    message: 'Une erreur inconnue est survenue',
    code: 'unknown-error',
  );
}
