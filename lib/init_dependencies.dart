import 'package:blog_bloom/core/secrets/app_secrets.dart';
import 'package:blog_bloom/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_bloom/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_bloom/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_login.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_signup.dart';
import 'package:blog_bloom/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
}

void _initAuth() {
  // We can also define type of the serviceLocator in the AuthRemoteDataSourceImpl but Get_It automatically does that for us
  // AuthRemoteDataSourceImpl(serviceLocator<SupabaseClient>()), we can do like this also
  serviceLocator.registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()));

  serviceLocator.registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()));

  serviceLocator.registerFactory(() => UserSignUp(serviceLocator()));

  serviceLocator.registerFactory(() => UserLogin(serviceLocator()));

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogin: serviceLocator(),
    ),
  );
}
