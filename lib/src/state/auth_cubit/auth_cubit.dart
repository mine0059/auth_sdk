import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:auth_sdk/src/models/auth_user.dart';
import 'package:auth_sdk/src/service/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._service) : super(AuthState.initial()) {
    _service.authStateChanges().listen(_handleAuthUpdates);
  }

  final AuthService _service;

  void _handleAuthUpdates(user) {
    if (user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final authUser = await _service.signInWithEmail(email, password);
      emit(AuthState(status: AuthStatus.authenticated, user: authUser));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final authUser = await _service.signUpWithEmail(email, password);
      emit(AuthState(status: AuthStatus.authenticated, user: authUser));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final authUser = await _service.signInWithGoogle();
      emit(AuthState(status: AuthStatus.authenticated, user: authUser));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
