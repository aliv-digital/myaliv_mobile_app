import 'package:equatable/equatable.dart';

abstract class RevPrepaidEvent extends Equatable {
  const RevPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class RevPrepaidStarted extends RevPrepaidEvent {
  const RevPrepaidStarted();
}

class RevAccountNumberChanged extends RevPrepaidEvent {
  final String value;
  const RevAccountNumberChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class RevNameChanged extends RevPrepaidEvent {
  final String value;
  const RevNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class RevAmountChanged extends RevPrepaidEvent {
  final String rawText; // "$ 0.00" / "0.00" / "200"
  const RevAmountChanged(this.rawText);

  @override
  List<Object?> get props => [rawText];
}

class RevSubmitPressed extends RevPrepaidEvent {
  const RevSubmitPressed();
}

class RevProceedPressed extends RevPrepaidEvent {
  const RevProceedPressed();
}

class RevNavigationConsumed extends RevPrepaidEvent {
  const RevNavigationConsumed();
}
