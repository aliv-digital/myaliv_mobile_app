import 'package:equatable/equatable.dart';

abstract class RevPaymentMethodPrepaidEvent extends Equatable {
  const RevPaymentMethodPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class RevPaymentMethodPrepaidStarted extends RevPaymentMethodPrepaidEvent {
  const RevPaymentMethodPrepaidStarted();
}

class RevPaymentMethodSelected extends RevPaymentMethodPrepaidEvent {
  final String methodId;
  const RevPaymentMethodSelected(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

class RevPayWithCardPressed extends RevPaymentMethodPrepaidEvent {
  const RevPayWithCardPressed();
}

class RevPayNowPressed extends RevPaymentMethodPrepaidEvent {
  const RevPayNowPressed();
}

class RevPaymentNavConsumed extends RevPaymentMethodPrepaidEvent {
  const RevPaymentNavConsumed();
}
