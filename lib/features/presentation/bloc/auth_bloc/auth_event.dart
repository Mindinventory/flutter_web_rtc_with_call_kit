part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  String username;

  LoginEvent({required this.username});
}

class SignUpEvent extends AuthEvent {
  User user;

  SignUpEvent({required this.user});
}

class MultipleLoginEvent extends AuthEvent {}

class UpdateFCMTokenEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}
