import 'package:blog_bloom/core/error/failure.dart';
import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignOut implements UseCase<void, NoParams> {
  final AuthRepository authRepository;

  UserSignOut(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.signOut();
  }
}
