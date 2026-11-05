import 'package:equatable/equatable.dart';
import '../model/guest_pay_bill_confirm_models.dart';

enum GuestPayBillConfirmLoadStatus { initial, loading, ready, failure }

enum GuestPayBillConfirmPayStatus { idle, loading, success, failure }

class GuestPayBillConfirmState extends Equatable {
  final GuestPayBillConfirmArgs args;

  final GuestPayBillConfirmLoadStatus loadStatus;
  final GuestPayBillConfirmPayStatus payStatus;
  final bool isTermsChecked;

  final double vat;
  final String? errorMessage;
  final String? lastOrderId;

  const GuestPayBillConfirmState({
    required this.args,
    required this.loadStatus,
    required this.payStatus,
    required this.isTermsChecked,
    required this.vat,
    required this.errorMessage,
    this.lastOrderId,
  });

  factory GuestPayBillConfirmState.initial({
    required GuestPayBillConfirmArgs args,
  }) {
    return GuestPayBillConfirmState(
      args: args,
      loadStatus: GuestPayBillConfirmLoadStatus.initial,
      payStatus: GuestPayBillConfirmPayStatus.idle,
      isTermsChecked: false,
      vat: 0.0,
      errorMessage: null,
      lastOrderId: null,
    );
  }

  double get subTotal => args.amount;
  double get total => args.amount + vat;

  GuestPayBillConfirmState copyWith({
    GuestPayBillConfirmLoadStatus? loadStatus,
    GuestPayBillConfirmPayStatus? payStatus,
    bool? isTermsChecked,
    double? vat,
    String? errorMessage,
    String? lastOrderId,
  }) {
    return GuestPayBillConfirmState(
      args: args,
      loadStatus: loadStatus ?? this.loadStatus,
      payStatus: payStatus ?? this.payStatus,
      isTermsChecked: isTermsChecked ?? this.isTermsChecked,
      vat: vat ?? this.vat,
      errorMessage: errorMessage,
      lastOrderId: lastOrderId ?? this.lastOrderId,
    );
  }

  @override
  List<Object?> get props => [
    args,
    loadStatus,
    payStatus,
    isTermsChecked,
    vat,
    errorMessage,
    lastOrderId,
  ];
}
