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

class ForgetPasswordSubmitted extends ForgetPasswordEvent {
  const ForgetPasswordSubmitted();
}
