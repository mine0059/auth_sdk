part of 'auth_cubit.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  error,
  tokenExpired,
}

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.unknown);
  }

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, user, errorMessage];
}
