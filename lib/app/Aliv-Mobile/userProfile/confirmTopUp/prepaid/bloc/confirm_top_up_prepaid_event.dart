import 'package:equatable/equatable.dart';

sealed class ConfirmTopUpPrepaidEvent extends Equatable {
  const ConfirmTopUpPrepaidEvent();

  @override
  List<Object?> get props => [];
}

final class ConfirmTopUpStarted extends ConfirmTopUpPrepaidEvent {
  final String customerName;
  final String customerPhone;
  final double amount;

  const ConfirmTopUpStarted({
    required this.customerName,
    required this.customerPhone,
    required this.amount,
  });

  @override
  List<Object?> get props => [customerName, customerPhone, amount];
}

final class PromoCodeChanged extends ConfirmTopUpPrepaidEvent {
  final String promoCode;
  const PromoCodeChanged(this.promoCode);

  @override
  List<Object?> get props => [promoCode];
}

final class PromoCodeApplied extends ConfirmTopUpPrepaidEvent {
  const PromoCodeApplied();
}

final class ContinuePressed extends ConfirmTopUpPrepaidEvent {
  const ContinuePressed();
}

final class TermsPressed extends ConfirmTopUpPrepaidEvent {
  const TermsPressed();
}
