import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthSignIn extends AuthEvent {
  final String email, password;
  AuthSignIn(this.email, this.password);
  @override List<Object?> get props => [email, password];
}

class AuthSignUp extends AuthEvent {
  final String email, password;
  AuthSignUp(this.email, this.password);
  @override List<Object?> get props => [email, password];
}

class AuthSignOut extends AuthEvent {}

class AuthGoogleSignIn extends AuthEvent {}

class AuthResetPassword extends AuthEvent {
  final String email;
  AuthResetPassword(this.email);
  @override List<Object?> get props => [email];
}