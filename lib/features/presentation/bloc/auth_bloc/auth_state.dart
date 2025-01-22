part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final String? message;

  AuthSuccessState({this.message});
}

class AuthFailureState extends AuthState {
  final String? message;

  AuthFailureState({this.message});
}

class AuthMultipleLoginState extends AuthState {}
