import 'package:equatable/equatable.dart';

import '../model/guest_pay_bill_models.dart';

abstract class GuestPayBillEvent extends Equatable {
  const GuestPayBillEvent();
  @override
  List<Object?> get props => [];
}

class GuestPayBillStarted extends GuestPayBillEvent {
  const GuestPayBillStarted();
}

class GuestPayBillServiceChanged extends GuestPayBillEvent {
  final BillService? service;
  const GuestPayBillServiceChanged(this.service);
  @override
  List<Object?> get props => [service];
}

// REV fields
class GuestPayBillAccountNumberChanged extends GuestPayBillEvent {
  final String value;
  const GuestPayBillAccountNumberChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class GuestPayBillNameChanged extends GuestPayBillEvent {
  final String value;
  const GuestPayBillNameChanged(this.value);
  @override
  List<Object?> get props => [value];
}

// ALIV Postpaid fields
class GuestPayBillMobileChanged extends GuestPayBillEvent {
  final String value;
  const GuestPayBillMobileChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class GuestPayBillConfirmMobileChanged extends GuestPayBillEvent {
  final String value;
  const GuestPayBillConfirmMobileChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class GuestPayBillCountryChanged extends GuestPayBillEvent {
  final PayBillCountry country;
  const GuestPayBillCountryChanged(this.country);
  @override
  List<Object?> get props => [country.flagEmoji, country.dialCode];
}

class GuestPayBillAmountChanged extends GuestPayBillEvent {
  final String value;
  const GuestPayBillAmountChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class GuestPayBillVerifyPressed extends GuestPayBillEvent {
  const GuestPayBillVerifyPressed();
}

class GuestPayBillSubmitPressed extends GuestPayBillEvent {
  const GuestPayBillSubmitPressed();
}
