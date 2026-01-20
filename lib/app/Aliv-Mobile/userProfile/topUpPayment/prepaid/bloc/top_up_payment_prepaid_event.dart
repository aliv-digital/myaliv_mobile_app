import 'package:equatable/equatable.dart';

sealed class TopUpPaymentPrepaidEvent extends Equatable {
  const TopUpPaymentPrepaidEvent();

  @override
  List<Object?> get props => [];
}

final class TopUpPaymentStarted extends TopUpPaymentPrepaidEvent {
  const TopUpPaymentStarted();
}

final class PaymentMethodSelected extends TopUpPaymentPrepaidEvent {
  final String paymentMethodId;
  const PaymentMethodSelected(this.paymentMethodId);

  @override
  List<Object?> get props => [paymentMethodId];
}

final class PayWithCardPressed extends TopUpPaymentPrepaidEvent {
  const PayWithCardPressed();
}

final class PayNowPressed extends TopUpPaymentPrepaidEvent {
  const PayNowPressed();
}
