import 'dart:io';

import 'package:blog_diego/feature/blog/domain/usecases/upload_blog_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  UploadBlogUsecase uploadBlogUsecase;

  BlogBloc(this.uploadBlogUsecase) : super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onblogUpload);
  }

  Future<void> _onblogUpload(BlogUpload event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final result = await uploadBlogUsecase(
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
      (success) => emit(BlogSucess()),
    );
  }
}
