import 'package:equatable/equatable.dart';

import '../repository/auto_renew_auth_prepaid_repository.dart';

abstract class AutoRenewAuthPrepaidEvent extends Equatable {
  const AutoRenewAuthPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class AutoRenewAuthPrepaidStarted extends AutoRenewAuthPrepaidEvent {
  final AutoRenewPaymentMethodType paymentMethod;

  const AutoRenewAuthPrepaidStarted({
    this.paymentMethod = AutoRenewPaymentMethodType.wallet,
  });

  @override
  List<Object?> get props => [paymentMethod];
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
