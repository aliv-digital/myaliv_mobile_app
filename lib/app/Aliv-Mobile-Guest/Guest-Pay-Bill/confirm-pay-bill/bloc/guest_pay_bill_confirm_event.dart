import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

abstract class GuestPayBillConfirmEvent extends Equatable {
  const GuestPayBillConfirmEvent();
  @override
  List<Object?> get props => [];
}

class GuestPayBillConfirmStarted extends GuestPayBillConfirmEvent {
  const GuestPayBillConfirmStarted();
}

class GuestPayBillConfirmPayNowPressed extends GuestPayBillConfirmEvent {
  const GuestPayBillConfirmPayNowPressed();
}

class GuestPayBillConfirmTermsCheckboxToggled extends GuestPayBillConfirmEvent {
  const GuestPayBillConfirmTermsCheckboxToggled();
}

class GuestPayBillConfirmFibrPayPressed extends GuestPayBillConfirmEvent {
  const GuestPayBillConfirmFibrPayPressed({required this.cardDetails});
  final NewCardDetails cardDetails;
  @override
  List<Object?> get props => [cardDetails];
}
