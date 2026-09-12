import 'dart:io';

import 'package:blog_diego/core/usecase/usecaase.dart';
import 'package:blog_diego/feature/blog/domain/entities/blog.dart';
import 'package:blog_diego/feature/blog/domain/usecases/get_all_blogs_usecase.dart';
import 'package:blog_diego/feature/blog/domain/usecases/upload_blog_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlogUsecase _uploadBlogUsecase;
  final GetAllBlogsUsecase _getAllBlogsUsecase;

  BlogBloc({
    required UploadBlogUsecase uploadBloguseCase,
    required GetAllBlogsUsecase getAllBlogsUsecase,
  }) : _uploadBlogUsecase = uploadBloguseCase,
       // ignore: prefer_initializing_formals
       _getAllBlogsUsecase = getAllBlogsUsecase,
       super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onblogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlogs);
  }


  void _onblogUpload(BlogUpload event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final result = await _uploadBlogUsecase(
      UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ),
    );
    result.fold(
      (failure) => emit(BlogFailure(failure.message)),
      (success) => emit(BlogUploadSuccess()),
    );
  }


  void _onFetchAllBlogs(
    BlogFetchAllBlogs event,
    Emitter<BlogState> emit,
  ) async {
    final res = await _getAllBlogsUsecase(NoParams());

    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogsDisplaySuccess(r)),
    );
  }
}