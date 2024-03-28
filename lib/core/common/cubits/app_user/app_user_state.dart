part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitialState extends AppUserState {}

final class AppUserLoggedInState extends AppUserState {
  final User user;

  AppUserLoggedInState(this.user);
}

// core cannot depend on other features
// but other features can be depend on core
