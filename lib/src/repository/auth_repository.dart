import 'dart:async';
import 'package:auth_sdk/src/service/auth_service.dart';
import '../models/auth_user.dart';

/// Repository class that provides headless authentication functionality.
/// This allows developers to use their own state management solution
/// without being forced to use BLoC/Cubit.
///
/// Use this for custom UI implementations where you want full control
/// over the authentication logic and state management.
class AuthRepository {
  AuthRepository(this._authService) {
    // Listen to auth state changes and update internal stream
    _authService.authStateChanges().listen((user) {
      _authStateController.add(user);
    });
  }

  final AuthService _authService;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  Stream<AuthUser?> get authStateStream => _authStateController.stream;

  /// Get the current authenticated user synchronously.
  /// Returns null if no user is authenticated.
  AuthUser? get currentUser => _authStateController.hasListener
      ? null
      : null; // We'll need to track this differently

  /// Sign in with email and password.
  ///
  /// Throws:
  /// - [InvalidCredentialsException] if credentials are wrong
  /// - [UserNotFoundException] if user doesn't exist
  /// - [NetworkException] if network error occurs
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    return await _authService.signInWithEmail(email, password);
  }

  /// Sign up with email and password.
  ///
  /// Throws:
  /// - [EmailAlreadyInUseException] if email is already registered
  /// - [WeakPasswordException] if password is too weak
  /// - [NetworkException] if network error occurs
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    return await _authService.signUpWithEmail(email, password);
  }

  /// Sign in with Google.
  ///
  /// Throws:
  /// - [NetworkException] if network error occurs
  /// - Generic [Exception] for other errors
  Future<AuthUser?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  /// Sign in with Apple (iOS only).
  ///
  /// Throws:
  /// - [UnimplementedError] as Apple Sign-In is not yet implemented
  Future<AuthUser?> signInWithApple() async {
    return await _authService.signInWithApple();
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Get the current user's ID token.
  ///
  /// [refresh] - If true, forces token refresh
  ///
  /// Returns the ID token string, or null if no user is authenticated.
  ///
  /// Throws:
  /// - [TokenExpiredException] if token is expired and refresh fails
  Future<String?> getIdToken({bool refresh = false}) async {
    return await _authService.getIdToken(refresh: refresh);
  }

  /// Dispose of resources
  void dispose() {
    _authStateController.close();
  }
}
