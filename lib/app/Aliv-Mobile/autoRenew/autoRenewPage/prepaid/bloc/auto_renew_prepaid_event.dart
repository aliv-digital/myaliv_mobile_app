import 'package:equatable/equatable.dart';

abstract class AutoRenewPrepaidEvent extends Equatable {
  const AutoRenewPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class AutoRenewPrepaidStarted extends AutoRenewPrepaidEvent {
  const AutoRenewPrepaidStarted();
}

class AutoRenewMethodSelected extends AutoRenewPrepaidEvent {
  final String methodId;
  const AutoRenewMethodSelected(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

class AutoRenewAddNewCardPressed extends AutoRenewPrepaidEvent {
  const AutoRenewAddNewCardPressed();
}

class AutoRenewSaveNewCardPressed extends AutoRenewPrepaidEvent {
  final int month;
  final int year;

  const AutoRenewSaveNewCardPressed({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class AutoRenewProceedPressed extends AutoRenewPrepaidEvent {
  const AutoRenewProceedPressed();
}

class AutoRenewHomePressed extends AutoRenewPrepaidEvent {
  const AutoRenewHomePressed();
}

class AutoRenewNavigationConsumed extends AutoRenewPrepaidEvent {
  const AutoRenewNavigationConsumed();
}
