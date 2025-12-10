import 'package:auth_sdk/src/models/auth_user.dart';
import 'package:auth_sdk/src/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../exceptions/exceptions.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUser.fromFirebaseUser(user);
    });
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthUser.fromFirebaseUser(cred.user);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthUser.fromFirebaseUser(cred.user);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _firebaseAuth.signInWithCredential(credential);
      return AuthUser.fromFirebaseUser(cred.user);
    } on FirebaseAuthException catch (e) {
      throw mapFirebaseError(e);
    }
  }

  @override
  Future<String?> getIdToken({bool refresh = false}) async {
    final user = _firebaseAuth.currentUser;
    return user?.getIdToken(refresh);
  }

  @override
  Future<AuthUser?> signInWithApple() {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  Exception mapFirebaseError(FirebaseAuthException e) {
    // Log for debugging
    debugPrint('🔴 Firebase Error Code: ${e.code}');
    debugPrint('🔴 Firebase Error Message: ${e.message}');

    switch (e.code) {
      // Invalid credentials - THIS IS THE ERROR YOU'RE SEEING
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return InvalidCredentialsException();

      // User not found
      case 'user-not-found':
        return UserNotFoundException();

      // Email issues
      case 'email-already-in-use':
        return EmailAlreadyInUseException();
      case 'invalid-email':
        return InvalidCredentialsException();

      // Password issues
      case 'weak-password':
        return WeakPasswordException();

      // Network issues
      case 'network-request-failed':
        return NetworkException();

      // Token issues
      case 'token-expired':
      case 'user-token-expired':
        return TokenExpiredException();

      // Catch-all for unmapped errors
      default:
        debugPrint('⚠️ UNMAPPED ERROR CODE: ${e.code}');
        return Exception(e.message ?? 'Unknown error occurred');
    }
  }
}
