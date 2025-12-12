import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:auth_sdk/src/models/auth_user.dart';
import 'package:auth_sdk/src/service/auth_service.dart';
import 'package:auth_sdk/src/exceptions/exceptions.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._service) : super(AuthState.initial()) {
    _service.authStateChanges().listen(_handleAuthUpdates);
  }

  final AuthService _service;

  void _handleAuthUpdates(user) {
    debugPrint('AuthCubit: Auth state update - User: ${user?.email ?? "null"}');
    if (user == null) {
      debugPrint('AuthCubit: Emitting UNAUTHENTICATED');
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    } else {
      debugPrint('AuthCubit: Emitting AUTHENTICATED');
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    }
  }

  /// Helper to extract clean error messages from exceptions
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      // Return clean message from our custom exceptions
      return error.message;
    } else if (error is Exception) {
      // Try to extract message from generic Exception
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11); // Remove "Exception: " prefix
      }
      return message;
    }
    return error.toString();
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final authUser = await _service.signInWithEmail(email, password);
      emit(AuthState(status: AuthStatus.authenticated, user: authUser));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
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
        errorMessage: _getErrorMessage(e),
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
        errorMessage: _getErrorMessage(e),
      ));
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> SignInWithApple() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final authUser = await _service.signInWithApple();
      emit(AuthState(status: AuthStatus.authenticated, user: authUser));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      ));
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
