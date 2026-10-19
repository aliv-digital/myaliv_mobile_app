import 'package:equatable/equatable.dart';

abstract class GuestPaymentMethodPrepaidEvent extends Equatable {
  const GuestPaymentMethodPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class GuestPaymentMethodPrepaidStarted extends GuestPaymentMethodPrepaidEvent {
  const GuestPaymentMethodPrepaidStarted();
}

class GuestPaymentMethodSelected extends GuestPaymentMethodPrepaidEvent {
  final String methodId;
  const GuestPaymentMethodSelected(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

class GuestPayWithCardPressed extends GuestPaymentMethodPrepaidEvent {
  const GuestPayWithCardPressed();
}

class GuestPayNowPressed extends GuestPaymentMethodPrepaidEvent {
  const GuestPayNowPressed();
}

class GuestPaymentNavConsumed extends GuestPaymentMethodPrepaidEvent {
  const GuestPaymentNavConsumed();
}
