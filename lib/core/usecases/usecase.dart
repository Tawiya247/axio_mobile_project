import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

// Classe de base pour les paramètres des cas d'utilisation
abstract class Params extends Equatable {
  @override
  List<Object?> get props => [];
}

// Classe de base pour les réponses des cas d'utilisation
abstract class Response extends Equatable {
  @override
  List<Object?> get props => [];
}
