// lib/login/login_event.dart
import 'package:equatable/equatable.dart';

import '../model/login_country_selection.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginPhoneChanged extends LoginEvent {
  final String phone;
  const LoginPhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginCountryChanged extends LoginEvent {
  final LoginCountrySelection selectedCountry;

  const LoginCountryChanged(this.selectedCountry);

  @override
  List<Object?> get props => [selectedCountry];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
