import 'package:equatable/equatable.dart';

sealed class GuestConfirmTopUpEvent extends Equatable {
  const GuestConfirmTopUpEvent();

  @override
  List<Object?> get props => [];
}

final class GuestConfirmTopUpStarted extends GuestConfirmTopUpEvent {
  final String phoneNumber;
  final double amount;

  const GuestConfirmTopUpStarted({
    required this.phoneNumber,
    required this.amount,
  });

  @override
  List<Object?> get props => [phoneNumber, amount];
}

final class GuestConfirmTopUpPayNowPressed extends GuestConfirmTopUpEvent {
  const GuestConfirmTopUpPayNowPressed();
}

final class GuestConfirmTopUpTermsPressed extends GuestConfirmTopUpEvent {
  const GuestConfirmTopUpTermsPressed();
}
