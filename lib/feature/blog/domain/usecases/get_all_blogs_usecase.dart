import 'package:blog_diego/core/error/failure.dart';
import 'package:blog_diego/core/usecase/usecaase.dart';
import 'package:blog_diego/feature/blog/domain/entities/blog.dart';
import 'package:blog_diego/feature/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogsUsecase implements UseCase<List<Blog>, NoParams> {
  final BlogRepository blogRepository;
  GetAllBlogsUsecase(this.blogRepository);

  @override
  Future<Either<Failure, List<Blog>>> call(NoParams params) async {
    return await blogRepository.getAllBlogs();
  }
}
