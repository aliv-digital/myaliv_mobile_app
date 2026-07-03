import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

sealed class TopUpPaymentPrepaidEvent extends Equatable {
  const TopUpPaymentPrepaidEvent();

  @override
  List<Object?> get props => [];
}

final class TopUpPaymentStarted extends TopUpPaymentPrepaidEvent {
  final double? amount;
  final String? recipientPhone;

  const TopUpPaymentStarted({this.amount, this.recipientPhone});

  @override
  List<Object?> get props => [amount, recipientPhone];
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

/// User confirmed the saved-card sheet — hit the top-up API with the
/// currently selected card token.
final class PaySavedCardConfirmed extends TopUpPaymentPrepaidEvent {
  const PaySavedCardConfirmed();
}

/// User submitted the Checkout sheet — hit the top-up API with fresh card
/// details.
final class PayWithCardConfirmed extends TopUpPaymentPrepaidEvent {
  final NewCardDetails details;

  const PayWithCardConfirmed(this.details);

  @override
  List<Object?> get props => [details];
}

/// View acknowledges it has pushed the receipt route, clears [navTarget].
final class PaymentNavConsumed extends TopUpPaymentPrepaidEvent {
  const PaymentNavConsumed();
}
