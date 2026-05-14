import 'package:equatable/equatable.dart';
import '../model/home_plans_payment_method_models.dart';

abstract class HomePlansPaymentMethodEvent extends Equatable {
  const HomePlansPaymentMethodEvent();

  @override
  List<Object?> get props => [];
}

class HomePlansPaymentMethodStarted extends HomePlansPaymentMethodEvent {
  final HomePlansSubscriberType subscriberType;
  final String phoneNumber;
  final double? amount;
  final String? vatNote;
  final List<HomePlansPaymentSelectedItem> selectedItems;

  const HomePlansPaymentMethodStarted({
    required this.subscriberType,
    this.phoneNumber = '',
    this.amount,
    this.vatNote,
    this.selectedItems = const <HomePlansPaymentSelectedItem>[],
  });

  @override
  List<Object?> get props => [
        subscriberType,
        phoneNumber,
        amount,
        vatNote,
        selectedItems,
      ];
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

class HomePlansPayFromWalletConfirmed extends HomePlansPaymentMethodEvent {
  final double walletBalance;

  const HomePlansPayFromWalletConfirmed({required this.walletBalance});

  @override
  List<Object?> get props => [walletBalance];
}

class HomePlansPayNowPressed extends HomePlansPaymentMethodEvent {
  const HomePlansPayNowPressed();
}

class HomePlansPaymentNavConsumed extends HomePlansPaymentMethodEvent {
  const HomePlansPaymentNavConsumed();
}
