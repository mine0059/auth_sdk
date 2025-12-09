import 'package:auth_sdk/src/models/auth_user.dart';

abstract class AuthService {
  Stream<AuthUser?> authStateChanges();

  Future<AuthUser?> signInWithEmail(String email, String password);
  Future<AuthUser?> signUpWithEmail(String email, String password);
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInWithApple();
  Future<void> signOut();
  Future<String?> getIdToken({bool refresh = false})
;}