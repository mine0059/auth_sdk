import 'package:auth_sdk/src/service/auth_service.dart';
import 'package:auth_sdk/src/state/auth_cubit/auth_cubit.dart';

import '../models/auth_user.dart';

class AuthRepository {
  static final AuthRepository instance = AuthRepository._internal();
  late AuthCubit _cubit;

  AuthRepository._internal();

  void initialize(AuthService service) {
    _cubit = AuthCubit(service);
  }

  Stream<AuthState> get authStateStream => _cubit.stream;

  AuthState get currentState => _cubit.state;

  Future<AuthUser?> signInWithEmail(String email, String password) async {
    await _cubit.signInWithEmail(email, password);
    return _cubit.state.user;
  }

  Future<AuthUser?> signInWithGoogle() async {
    await _cubit.signInWithGoogle();
    return _cubit.state.user;
  }

  Future<void> signOut() async {
    await _cubit.signOut();
  }
}