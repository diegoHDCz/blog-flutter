import 'dart:io';

import 'package:blog_diego/core/error/exceptions.dart';
import 'package:blog_diego/core/error/failure.dart';
import 'package:blog_diego/feature/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_diego/feature/blog/data/models/blog_model.dart';
import 'package:blog_diego/feature/blog/domain/entities/blog.dart';
import 'package:blog_diego/feature/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;

  BlogRepositoryImpl(this.blogRemoteDataSource);

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      BlogModel blogModel = BlogModel(
        id: const Uuid().v4(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        topics: topics,
        updatedAt: DateTime.now(),
      );
      final blogImage = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blog: blogModel,
      );

      blogModel = blogModel.copyWith(imageUrl: blogImage);

      final blogUploaded = await blogRemoteDataSource.uploadBlog(blogModel);

      return right(blogUploaded);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
        final blogs = await blogRemoteDataSource.getAllBlogs();

        return right(blogs);
    }on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
