import 'package:blog_diego/core/usecase/usecaase.dart';
import 'package:blog_diego/core/common/entities/user.dart';
import 'package:blog_diego/feature/auth/domain/usecases/current_user.dart';
import 'package:blog_diego/feature/auth/domain/usecases/user_login.dart';
import 'package:blog_diego/feature/auth/domain/usecases/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;

  AuthBloc({required this._userSignUp, required this._userLogin, required this._currentUser})
    : super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
  }

  void _isUserLoggedIn(AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _currentUser.call(NoParams());
    res.fold(
      (onLeft) {
        emit(AuthFailure(onLeft.message));
      },
      (onRight) {
        emit(AuthSuccess(onRight));
      },
    );
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignUp.call(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    res.fold(
      (onLeft) {
        emit(AuthFailure(onLeft.message));
      },
      (onRight) {
        emit(AuthSuccess(onRight));
      },
    );
  }

  void _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _userLogin(
      UserLoginParams(email: event.email, password: event.password),
    );
    res.fold(
      (onLeft) {
        emit(AuthFailure(onLeft.message));
      },
      (onRight) {
        emit(AuthSuccess(onRight));
      },
    );
  }
}
