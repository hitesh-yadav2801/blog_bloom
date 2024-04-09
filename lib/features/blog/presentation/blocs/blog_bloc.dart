import 'dart:async';
import 'dart:io';

import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/domain/usecases/delete_blog.dart';
import 'package:blog_bloom/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_bloom/features/blog/domain/usecases/get_my_blogs.dart';
import 'package:blog_bloom/features/blog/domain/usecases/update_blog.dart';
import 'package:blog_bloom/features/blog/domain/usecases/upload_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';

part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;
  final GetMyBlogs _getMyBlogs;
  final DeleteBlog _deleteBlog;
  final UpdateBlog _updateBlog;

  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
    required GetMyBlogs getMyBlogs,
    required DeleteBlog deleteBlog,
    required UpdateBlog updateBlog,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        _getMyBlogs = getMyBlogs,
        _deleteBlog = deleteBlog,
        _updateBlog = updateBlog,
        super(BlogInitialState()) {
    on<BlogEvent>((event, emit) => emit(BlogLoadingState()));
    on<BlogUploadEvent>(_onBlogUpload);
    on<BlogFetchAllBlogsEvent>(_onFetchAllBlogs);
    on<BlogFetchMyBlogsEvent>(_onFetchMyBlogs);
    on<BlogDeleteEvent>(_onDeleteBlog);
    on<BlogUpdateEvent>(_onUpdateBlog);
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

  void _onFetchAllBlogs(
      BlogFetchAllBlogsEvent event, Emitter<BlogState> emit) async {
    final response = await _getAllBlogs(NoParams());
    response.fold(
      (l) => emit(BlogFailureState(l.message)),
      (r) => emit(BlogDisplaySuccessState(r)),
    );
  }

  void _onFetchMyBlogs(
      BlogFetchMyBlogsEvent event, Emitter<BlogState> emit) async {
    final response = event.blogs;

    emit(BlogMyDisplaySuccessState(response!));

    // final response = await _getMyBlogs(NoParams());
    // response.fold(
    //   (l) => emit(BlogFailureState(l.message)),
    //   (r) => emit(BlogMyDisplaySuccessState(r)),
    // );
  }

  void _onDeleteBlog(BlogDeleteEvent event, Emitter<BlogState> emit) async {
    final response = await _deleteBlog(event.blogId);
    response.fold(
      (l) => emit(BlogFailureState(l.message)),
      (r) => emit(BlogDeleteSuccessState(r)),
    );
  }

  void _onUpdateBlog(BlogUpdateEvent event, Emitter<BlogState> emit) async {
    final response = await _updateBlog(
      UpdateBlogParams(
        posterId: event.posterId,
        blogId: event.blogId,
        title: event.title,
        content: event.content,
        topics: event.topics,
        image: event.image,
      ),
    );
    response.fold(
      (l) => emit(BlogFailureState(l.message)),
      (r) => emit(BlogUpdateSuccessState(r)),
    );
  }
}
