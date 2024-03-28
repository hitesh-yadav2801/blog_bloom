import 'dart:async';
import 'dart:io';

import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_bloom/features/blog/domain/usecases/upload_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';

part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;

  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        super(BlogInitialState()) {
    on<BlogEvent>((event, emit) => emit(BlogLoadingState()));
    on<BlogUploadEvent>(_onBlogUpload);
    on<BlogFetchAllBlogsEvent>(_onFetchAllBlogs);
  }

  void _onBlogUpload(BlogUploadEvent event, Emitter<BlogState> emit) async {
    final response = await _uploadBlog(
      UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ),
    );
    response.fold(
      (l) => emit(BlogFailureState(l.message)),
      (r) => emit(BlogUploadSuccessState()),
    );
  }

  void _onFetchAllBlogs(BlogFetchAllBlogsEvent event, Emitter<BlogState> emit) async {
    final response = await _getAllBlogs(NoParams());
    response.fold(
      (l) => emit(BlogFailureState(l.message)),
      (r) => emit(BlogDisplaySuccessState(r)),
    );
  }
}
