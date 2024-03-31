import 'package:blog_bloom/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_bloom/core/network/connection_checker.dart';
import 'package:blog_bloom/core/secrets/app_secrets.dart';
import 'package:blog_bloom/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_bloom/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_bloom/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_bloom/features/auth/domain/usecases/current_user.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_login.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_signup.dart';
import 'package:blog_bloom/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:blog_bloom/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blog_bloom/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_bloom/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_bloom/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_bloom/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_bloom/features/blog/domain/usecases/upload_blog.dart';
import 'package:blog_bloom/features/blog/presentation/blocs/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'init_dependencies_main.dart';


