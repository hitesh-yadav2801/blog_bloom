import 'dart:io';
import 'package:blog_bloom/core/error/failure.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });

  Future<Either<Failure, List<Blog>>> getAllBlogs();


  Future<Either<Failure, List<Blog>>> getMyBlogs();


  Future<Either<Failure, Blog>> deleteBlog(String blogId);


  Future<Either<Failure, Blog>> updateBlog({
    required File image,
    required String posterId,
    required String blogId,
    required String title,
    required String content,
    required List<String> topics,
  });
}