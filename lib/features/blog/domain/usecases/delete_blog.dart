import 'package:blog_bloom/core/error/failure.dart';
import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteBlog implements UseCase<Blog, String> {
  final BlogRepository blogRepository;

  DeleteBlog(this.blogRepository);

  @override
  Future<Either<Failure, Blog>> call(String params) async {
    return await blogRepository.deleteBlog(params);
  }
}
