import 'package:blog_diego/core/error/failure.dart';
import 'package:blog_diego/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();
}