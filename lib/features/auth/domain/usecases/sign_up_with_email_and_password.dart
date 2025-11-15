import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailAndPassword
    implements UseCase<UserEntity, SignUpWithEmailAndPasswordParams> {
  final AuthRepository repository;

  const SignUpWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
    SignUpWithEmailAndPasswordParams params,
  ) async {
    try {
      final result = await repository.signUpWithEmailAndPassword(
        name: params.name,
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

class SignUpWithEmailAndPasswordParams extends Params {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  SignUpWithEmailAndPasswordParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [name, email, password, confirmPassword];
}
