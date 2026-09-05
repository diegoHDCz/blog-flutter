import 'package:blog_diego/core/error/failure.dart';
import 'package:blog_diego/core/usecase/usecaase.dart';
import 'package:blog_diego/core/common/entities/user.dart';
import 'package:blog_diego/feature/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository repository;

  const UserSignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    return await repository.signUpWithEmail(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignUpParams {
  final String name;
  final String email;
  final String password;

  UserSignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
