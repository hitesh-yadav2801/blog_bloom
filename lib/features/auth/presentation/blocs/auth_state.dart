part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);
}

final class AuthSuccessState extends AuthState {
  final User user;

  const AuthSuccessState(this.user);
}

final class AuthLogoutSuccessState extends AuthState {}
