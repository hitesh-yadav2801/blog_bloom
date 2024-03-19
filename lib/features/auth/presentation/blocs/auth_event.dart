part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  AuthSignUpEvent({
    required this.email,
    required this.password,
    required this.name,
  });
}
