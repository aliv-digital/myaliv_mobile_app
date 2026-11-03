import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/payment_option.dart';

class GuestPurchasePlanRouteArgs extends Equatable {
  const GuestPurchasePlanRouteArgs({
    required this.phoneNumber,
    required this.paymentOption,
  });

  final String phoneNumber;
  final PaymentOption paymentOption;

  @override
  List<Object?> get props => [phoneNumber, paymentOption];
}
