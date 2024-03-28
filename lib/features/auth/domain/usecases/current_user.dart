import 'package:blog_bloom/core/common/entities/user.dart';
import 'package:blog_bloom/core/error/failure.dart';
import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  CurrentUser(this.authRepository);
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
  
}

