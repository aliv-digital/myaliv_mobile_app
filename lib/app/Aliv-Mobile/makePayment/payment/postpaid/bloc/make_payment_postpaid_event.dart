import 'package:equatable/equatable.dart';

abstract class MakePaymentPostPaidEvent extends Equatable {
  const MakePaymentPostPaidEvent();

  @override
  List<Object?> get props => [];
}

class MakePaymentPostPaidStarted extends MakePaymentPostPaidEvent {
  const MakePaymentPostPaidStarted();
}

class MpAmountOptionChanged extends MakePaymentPostPaidEvent {
  final MpAmountOption option;
  const MpAmountOptionChanged(this.option);

  @override
  List<Object?> get props => [option];
}

class MpCustomAmountChanged extends MakePaymentPostPaidEvent {
  final String value;
  const MpCustomAmountChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class MpTermsToggled extends MakePaymentPostPaidEvent {
  final bool value;
  const MpTermsToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class MpPaymentMethodSelected extends MakePaymentPostPaidEvent {
  final int index;
  const MpPaymentMethodSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class MpPayNowPressed extends MakePaymentPostPaidEvent {
  const MpPayNowPressed();
}

class MpNavConsumed extends MakePaymentPostPaidEvent {
  const MpNavConsumed();
}

enum MpAmountOption { current, other }
