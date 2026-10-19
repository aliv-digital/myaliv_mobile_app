import 'package:equatable/equatable.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

class SecurityStarted extends SecurityEvent {
  const SecurityStarted();
}

class SecurityNavConsumed extends SecurityEvent {
  const SecurityNavConsumed();
}

class SecurityHomePressed extends SecurityEvent {
  const SecurityHomePressed();
}
