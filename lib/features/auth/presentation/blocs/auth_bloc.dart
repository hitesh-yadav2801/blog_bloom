import 'package:blog_bloom/features/auth/domain/entities/user.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_login.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;

  AuthBloc(
    {
    required UserSignUp userSignUp,
    required UserLogin userLogin
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        super(AuthInitialState()) {
    on<AuthSignUpEvent>(_onAuthSignUp);
    on<AuthLoginEvent>(_onAuthLogin);
  }
  void _onAuthSignUp(AuthSignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final response = await _userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    response.fold(
          (failure) => emit(AuthFailureState(failure.message)),
          (user) => emit(AuthSuccessState(user)),
    );
  }

  void _onAuthLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final response = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    response.fold(
          (failure) => emit(AuthFailureState(failure.message)),
          (user) => emit(AuthSuccessState(user)),
    );
  }
}
