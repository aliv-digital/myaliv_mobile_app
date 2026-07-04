import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

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
  final String token;
  const MpPaymentMethodSelected(this.token);

  @override
  List<Object?> get props => [token];
}

class MpPayWithCardSelected extends MakePaymentPostPaidEvent {
  const MpPayWithCardSelected();
}

class MpPayNowPressed extends MakePaymentPostPaidEvent {
  const MpPayNowPressed();
}

/// Fired after the user confirms payment with the currently selected saved
/// card (via [SavedCardPaymentBottomSheet]).
class MpPaySavedCardConfirmed extends MakePaymentPostPaidEvent {
  const MpPaySavedCardConfirmed();
}

/// Fired after the user completes the new-card checkout sheet.
class MpPayWithCardConfirmed extends MakePaymentPostPaidEvent {
  final NewCardDetails details;
  const MpPayWithCardConfirmed(this.details);

  @override
  List<Object?> get props => [details];
}

class MpNavConsumed extends MakePaymentPostPaidEvent {
  const MpNavConsumed();
}

enum MpAmountOption { current, other }
