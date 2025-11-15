import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.code, this.stackTrace});

  @override
  List<Object?> get props => [message, code, stackTrace];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

// Erreurs liées au serveur
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.stackTrace});
}

// Erreurs de connexion
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message, {super.code, super.stackTrace});
}

// Erreurs d'authentification
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code, super.stackTrace});
}

// Erreurs de validation
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.stackTrace});
}

// Erreurs d'autorisation
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, {super.code, super.stackTrace});
}

// Erreurs de cache
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.stackTrace});
}

// Erreurs de format
class FormatFailure extends Failure {
  const FormatFailure(super.message, {super.code, super.stackTrace});
}

// Erreurs inattendues
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code, super.stackTrace});
}
