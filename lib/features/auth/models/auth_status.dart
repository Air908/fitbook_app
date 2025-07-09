abstract class AuthStatus {}

class AuthInitial extends AuthStatus {}

class AuthLoading extends AuthStatus {}

class AuthSuccess extends AuthStatus {
  final String message;
  AuthSuccess(this.message);
}

class AuthFailure extends AuthStatus {
  final String message;
  AuthFailure(this.message);
}

class AuthAuthenticated extends AuthStatus {
  final dynamic user;
  AuthAuthenticated(this.user);
}
