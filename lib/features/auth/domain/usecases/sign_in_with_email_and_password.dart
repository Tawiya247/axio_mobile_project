import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailAndPassword
    implements UseCase<UserEntity, SignInWithEmailAndPasswordParams> {
  final AuthRepository repository;

  const SignInWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
    SignInWithEmailAndPasswordParams params,
  ) async {
    try {
      final result = await repository.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      return result.fold(
        (authError) => Left(
          AuthenticationFailure(authError.message, code: authError.code),
        ),
        (user) => Right(user),
      );
    } catch (e, stackTrace) {
      return Left(
        UnexpectedFailure(
          'An unexpected error occurred',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

class SignInWithEmailAndPasswordParams extends Params {
  final String email;
  final String password;

  SignInWithEmailAndPasswordParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
