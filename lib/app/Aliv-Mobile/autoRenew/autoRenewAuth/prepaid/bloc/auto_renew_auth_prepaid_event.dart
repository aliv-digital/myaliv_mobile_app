import 'package:equatable/equatable.dart';

import '../repository/auto_renew_auth_prepaid_repository.dart';

abstract class AutoRenewAuthPrepaidEvent extends Equatable {
  const AutoRenewAuthPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class AutoRenewAuthPrepaidStarted extends AutoRenewAuthPrepaidEvent {
  final AutoRenewPaymentMethodType paymentMethod;
  final String? cardToken;
  final String? cardLastDigits;

  const AutoRenewAuthPrepaidStarted({
    this.paymentMethod = AutoRenewPaymentMethodType.wallet,
    this.cardToken,
    this.cardLastDigits,
  });

  @override
  List<Object?> get props => [paymentMethod, cardToken, cardLastDigits];
}

class AutoRenewAuthNameChanged extends AutoRenewAuthPrepaidEvent {
  final String name;

  const AutoRenewAuthNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class AutoRenewAuthSubmitPressed extends AutoRenewAuthPrepaidEvent {
  const AutoRenewAuthSubmitPressed();
}

class AutoRenewAuthHomePressed extends AutoRenewAuthPrepaidEvent {
  const AutoRenewAuthHomePressed();
}

class AutoRenewAuthNavigationConsumed extends AutoRenewAuthPrepaidEvent {
  const AutoRenewAuthNavigationConsumed();
}
