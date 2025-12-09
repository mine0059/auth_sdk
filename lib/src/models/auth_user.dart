import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    this.email,
    this.name,
    this.photo,
  });

  factory AuthUser.fromFirebaseUser(dynamic user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      photo: user.photoURL,
    );
  }

  final String uid;
  final String? name;
  final String? email;
  final String? photo;
  
  @override
  List<Object?> get props => [uid, email, name, photo];
}