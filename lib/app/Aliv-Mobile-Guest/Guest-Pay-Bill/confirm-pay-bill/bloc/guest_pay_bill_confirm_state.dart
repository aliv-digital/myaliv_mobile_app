import 'package:equatable/equatable.dart';
import '../model/guest_pay_bill_confirm_models.dart';

enum GuestPayBillConfirmLoadStatus { initial, loading, ready, failure }
enum GuestPayBillConfirmPayStatus { idle, loading, success, failure }

class GuestPayBillConfirmState extends Equatable {
  final GuestPayBillConfirmArgs args;

  final GuestPayBillConfirmLoadStatus loadStatus;
  final GuestPayBillConfirmPayStatus payStatus;

  final double vat;
  final String? errorMessage;

  const GuestPayBillConfirmState({
    required this.args,
    required this.loadStatus,
    required this.payStatus,
    required this.vat,
    required this.errorMessage,
  });

  factory GuestPayBillConfirmState.initial({
    required GuestPayBillConfirmArgs args,
  }) {
    return GuestPayBillConfirmState(
      args: args,
      loadStatus: GuestPayBillConfirmLoadStatus.initial,
      payStatus: GuestPayBillConfirmPayStatus.idle,
      vat: 0.0,
      errorMessage: null,
    );
  }

  double get subTotal => args.amount;
  double get total => args.amount + vat;

  GuestPayBillConfirmState copyWith({
    GuestPayBillConfirmLoadStatus? loadStatus,
    GuestPayBillConfirmPayStatus? payStatus,
    double? vat,
    String? errorMessage,
  }) {
    return GuestPayBillConfirmState(
      args: args,
      loadStatus: loadStatus ?? this.loadStatus,
      payStatus: payStatus ?? this.payStatus,
      vat: vat ?? this.vat,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [args, loadStatus, payStatus, vat, errorMessage];
}
