import 'package:equatable/equatable.dart';
import '../model/home_plans_payment_method_models.dart';

abstract class HomePlansPaymentMethodEvent extends Equatable {
  const HomePlansPaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class HomePlansPaymentMethodStarted extends HomePlansPaymentMethodEvent {
  final HomePlansSubscriberType subscriberType;
  final double walletBalance;
  final double? amount;
  final String? vatNote;

  const HomePlansPaymentMethodStarted({
    required this.subscriberType,
    required this.walletBalance,
    this.amount,
    this.vatNote,
  });

  @override
  List<Object?> get props => [subscriberType, walletBalance, amount, vatNote];
}

class HomePlansPaymentMethodSelected extends HomePlansPaymentMethodEvent {
  final String methodId;
  const HomePlansPaymentMethodSelected(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

class HomePlansPayWithCardPressed extends HomePlansPaymentMethodEvent {
  const HomePlansPayWithCardPressed();
}

class HomePlansPayFromWalletPressed extends HomePlansPaymentMethodEvent {
  const HomePlansPayFromWalletPressed();
}

class HomePlansPayNowPressed extends HomePlansPaymentMethodEvent {
  const HomePlansPayNowPressed();
}

class HomePlansPaymentNavConsumed extends HomePlansPaymentMethodEvent {
  const HomePlansPaymentNavConsumed();
}
