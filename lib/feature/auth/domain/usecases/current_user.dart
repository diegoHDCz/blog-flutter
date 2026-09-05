import 'package:blog_diego/core/error/failure.dart';
import 'package:blog_diego/core/usecase/usecaase.dart';
import 'package:blog_diego/core/common/entities/user.dart';
import 'package:blog_diego/feature/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements UseCase<User, NoParams> {
   final AuthRepository repository;

   CurrentUser(this.repository);

   @override
   Future<Either<Failure, User>> call(NoParams params) async {
     return await repository.currentUser();
   }
 }