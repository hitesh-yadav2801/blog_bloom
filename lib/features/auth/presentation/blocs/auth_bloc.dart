import 'dart:async';

import 'package:blog_bloom/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_bloom/core/common/entities/user.dart';
import 'package:blog_bloom/core/usecase/usecase.dart';
import 'package:blog_bloom/features/auth/domain/usecases/current_user.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_login.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_signout.dart';
import 'package:blog_bloom/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final UserSignOut _userSignOut;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserSignOut userSignOut,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userSignOut = userSignOut,
        super(AuthInitialState()) {
    on<AuthEvent>((_, emit) => emit(AuthLoadingState()));
    on<AuthSignUpEvent>(_onAuthSignUp);
    on<AuthLoginEvent>(_onAuthLogin);
    on<AuthIsUserLoggedInEvent>(_onAuthIsUserLoggedIn);
    on<AuthLogoutEvent>(_onAuthLogout);
  }

  void _onAuthSignUp(AuthSignUpEvent event, Emitter<AuthState> emit) async {
    final response = await _userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    response.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    final response = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    response.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthIsUserLoggedIn(
      AuthIsUserLoggedInEvent event, Emitter<AuthState> emit) async {
    final response = await _currentUser(NoParams());

    response.fold(
      (l) => emit(AuthFailureState(l.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccessState(user));
  }

  void _onAuthLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    final response = await _userSignOut(NoParams());
    response.fold(
      (l) => emit(AuthFailureState(l.message)),
      (r) => emit(AuthLogoutSuccessState()),
    );
  }
}
