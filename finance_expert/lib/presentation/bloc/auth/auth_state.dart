import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  const AuthAuthenticated(this.token);

  @override
  List<Object?> get props => [token];
}

class AuthUnauthenticated extends AuthState {}

class AuthPasswordResetEmailSent extends AuthState {}

class AuthTwoFactorRequired extends AuthState {
  final String email;
  final String token;
  const AuthTwoFactorRequired(this.email, this.token);

  @override
  List<Object?> get props => [email, token];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
