import 'package:blog_bloom/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_bloom/core/secrets/app_secrets.dart';
import 'package:blog_bloom/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_bloom/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_bloom/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_bloom/features/auth/domain/usecases/current_user.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_login.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_signup.dart';
import 'package:blog_bloom/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:blog_bloom/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_bloom/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_bloom/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_bloom/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_bloom/features/blog/domain/usecases/upload_blog.dart';
import 'package:blog_bloom/features/blog/presentation/blocs/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  // core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initAuth() {
  // We can also define type of the serviceLocator in the AuthRemoteDataSourceImpl but Get_It automatically does that for us
  // AuthRemoteDataSourceImpl(serviceLocator<SupabaseClient>()), we can do like this also

  // This is Data Source
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // This is repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
      ),
    )
    // This is use case
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    // This is use case
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    // This is use case
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    // This is Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initBlog() {

  // Data Source
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
      ),
    )
    // Use case
    ..registerFactory(
      () => UploadBlog(
        serviceLocator(),
      ),
    )
    // Use case
    ..registerFactory(
      () => GetAllBlogs(serviceLocator()),
    )
    // Bloc
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator(), getAllBlogs: serviceLocator(),
      ),
    );
}
