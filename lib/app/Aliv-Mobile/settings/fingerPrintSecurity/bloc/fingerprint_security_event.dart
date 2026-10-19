import 'package:equatable/equatable.dart';

abstract class FingerPrintSecurityEvent extends Equatable {
  const FingerPrintSecurityEvent();

  @override
  List<Object?> get props => [];
}

class FingerPrintSecurityStarted extends FingerPrintSecurityEvent {
  const FingerPrintSecurityStarted();
}

class AgreePressed extends FingerPrintSecurityEvent {
  const AgreePressed();
}

class FingerPrintSecurityNavConsumed extends FingerPrintSecurityEvent {
  const FingerPrintSecurityNavConsumed();
}
