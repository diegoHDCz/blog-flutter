import 'dart:io';

import 'package:blog_diego/core/error/failure.dart';
import 'package:blog_diego/core/usecase/usecaase.dart';
import 'package:blog_diego/feature/blog/domain/entities/blog.dart';
import 'package:blog_diego/feature/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';


class UploadBlogUsecase implements UseCase<Blog, UploadBlogParams> {
  final BlogRepository blogRepository;
  UploadBlogUsecase(this.blogRepository);

  @override
  Future<Either<Failure, Blog>> call(UploadBlogParams params) async {
    return await blogRepository.uploadBlog(
      image: params.image,
      title: params.title,
      content: params.content,
      posterId: params.posterId,
      topics: params.topics,
    );
  }
}

class UploadBlogParams {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;

  UploadBlogParams({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}

