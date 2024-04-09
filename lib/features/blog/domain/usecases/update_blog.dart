import 'dart:io';

import 'package:blog_bloom/core/error/failure.dart';
import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateBlog implements UseCase<Blog, UpdateBlogParams> {
  final BlogRepository blogRepository;

  UpdateBlog(this.blogRepository);

  @override
  Future<Either<Failure, Blog>> call(params) async {
    return await blogRepository.updateBlog(
      image: params.image,
      posterId: params.posterId,
      blogId: params.blogId,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class UpdateBlogParams {
  final File image;
  final String posterId;
  final String blogId;
  final String title;
  final String content;
  final List<String> topics;

  UpdateBlogParams({
    required this.image,
    required this.posterId,
    required this.blogId,
    required this.title,
    required this.content,
    required this.topics,
  });
}
