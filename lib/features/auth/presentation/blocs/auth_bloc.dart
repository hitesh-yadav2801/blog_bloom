import 'package:blog_bloom/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;

  AuthBloc({required UserSignUp userSignUp})
      : _userSignUp = userSignUp,
        super(AuthInitialState()) {
    on<AuthSignUpEvent>((event, emit) async {
      final response = await _userSignUp(
        UserSignUpParams(
          email: event.email,
          password: event.password,
          name: event.name,
        ),
      );
      response.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (uid) => emit(AuthSuccessState(uid)),
      );
    });
  }
}
