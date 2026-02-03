import 'package:equatable/equatable.dart';

abstract class RevConfirmationPrepaidEvent extends Equatable {
  const RevConfirmationPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class RevConfirmationStarted extends RevConfirmationPrepaidEvent {
  const RevConfirmationStarted();
}

class RevPromoCodeChanged extends RevConfirmationPrepaidEvent {
  final String value;
  const RevPromoCodeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class RevPromoApplyPressed extends RevConfirmationPrepaidEvent {
  const RevPromoApplyPressed();
}

class RevContinuePressed extends RevConfirmationPrepaidEvent {
  const RevContinuePressed();
}

// ✅ NEW: checkbox toggle
class RevTermsToggled extends RevConfirmationPrepaidEvent {
  final bool value;
  const RevTermsToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class RevNavConsumed extends RevConfirmationPrepaidEvent {
  const RevNavConsumed();
}
