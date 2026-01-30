import 'package:equatable/equatable.dart';

abstract class PrivacyEvent extends Equatable {
  const PrivacyEvent();

  @override
  List<Object?> get props => [];
}

class PrivacyStarted extends PrivacyEvent {
  const PrivacyStarted();
}

class PrivacyNavConsumed extends PrivacyEvent {
  const PrivacyNavConsumed();
}

class PrivacyHomePressed extends PrivacyEvent {
  const PrivacyHomePressed();
}
