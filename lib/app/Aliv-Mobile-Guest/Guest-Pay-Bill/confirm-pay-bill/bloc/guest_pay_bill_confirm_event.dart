import 'package:equatable/equatable.dart';

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
