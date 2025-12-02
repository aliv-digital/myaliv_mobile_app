import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInPressed extends AuthEvent {
  final String phoneNumber;
  final String password;

  const SignInPressed({required this.phoneNumber, required this.password});

  @override
  List<Object> get props => [phoneNumber, password];
}
