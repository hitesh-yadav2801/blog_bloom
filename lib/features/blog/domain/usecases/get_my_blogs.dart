import 'package:blog_bloom/core/error/failure.dart';
import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/blog/domain/entities/blog.dart';
import 'package:blog_bloom/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetMyBlogs implements UseCase<List<Blog>, NoParams> {
  final BlogRepository blogRepository;

  GetMyBlogs(this.blogRepository);

  @override
  Future<Either<Failure, List<Blog>>> call(NoParams params) async {
    return await blogRepository.getMyBlogs();
  }
}
