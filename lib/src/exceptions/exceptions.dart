abstract class AuthException implements Exception {
  AuthException(this.message, this.code);
  final String message;
  final String code;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
     : super('Invalid email or password', 'invalid-credentials');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() 
    : super('User account does not exist', 'user-not-found');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException() : super('Email already in use', 'email-in-use');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException() : super('Weak password', 'password not strong');
}

class TokenExpiredException extends AuthException {
  TokenExpiredException() : super('Session expired', 'token-expired');
}

class NetworkException extends AuthException {
  NetworkException() : super('Network error occurred', 'network-error');
}