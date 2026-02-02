import 'package:equatable/equatable.dart';

abstract class MakePaymentConfirmationPostPaidEvent extends Equatable {
  const MakePaymentConfirmationPostPaidEvent();

  @override
  List<Object?> get props => [];
}

class MakePaymentConfirmationPostPaidStarted
    extends MakePaymentConfirmationPostPaidEvent {
  const MakePaymentConfirmationPostPaidStarted();
}

class MakePaymentPromoCodeChanged extends MakePaymentConfirmationPostPaidEvent {
  final String value;
  const MakePaymentPromoCodeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class MakePaymentPromoApplyPressed
    extends MakePaymentConfirmationPostPaidEvent {
  const MakePaymentPromoApplyPressed();
}

class MakePaymentContinuePressed extends MakePaymentConfirmationPostPaidEvent {
  const MakePaymentContinuePressed();
}

class MakePaymentNavConsumed extends MakePaymentConfirmationPostPaidEvent {
  const MakePaymentNavConsumed();
}
