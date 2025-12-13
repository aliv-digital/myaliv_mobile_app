// lib/login/login_event.dart
import 'package:equatable/equatable.dart';

abstract class ForgetPasswordEvent extends Equatable {
  const ForgetPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgetPasswordPhoneChanged extends ForgetPasswordEvent {
  final String phone;
  const ForgetPasswordPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class ForgetPasswordPasswordChanged extends ForgetPasswordEvent {
  final String password;
  const ForgetPasswordPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class ForgetPasswordSubmitted extends ForgetPasswordEvent {
  const ForgetPasswordSubmitted();
}
