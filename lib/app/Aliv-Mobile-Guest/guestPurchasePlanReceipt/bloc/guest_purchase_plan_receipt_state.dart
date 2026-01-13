import 'package:equatable/equatable.dart';

enum GuestPurchasePlanReceiptStatus { initial }

///  Dynamic receipt row model
class ReceiptDetailItem extends Equatable {
  final String label;
  final String value;
  final bool valueBold;

  const ReceiptDetailItem({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  List<Object?> get props => [label, value, valueBold];
}

class GuestPurchasePlanReceiptData extends Equatable {
  final String leftType; // top up
  final String rightType; // prepaid
  final String dateText; // Mar 22, 2023
  final String timeText; // 07:30 am
  final String phoneNumber; // 242-801-1616
  final String paymentMethod; // credit card
  final double amount; // 15.00

  /// Dynamic list of rows for ReceiptDetailRow()
  final List<ReceiptDetailItem> details;

  const GuestPurchasePlanReceiptData({
    required this.leftType,
    required this.rightType,
    required this.dateText,
    required this.timeText,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.amount,
    required this.details,
  });

  @override
  List<Object?> get props => [
    leftType,
    rightType,
    dateText,
    timeText,
    phoneNumber,
    paymentMethod,
    amount,
    details,
  ];
}

class GuestPurchasePlanReceiptState extends Equatable {
  final GuestPurchasePlanReceiptStatus status;
  final GuestPurchasePlanReceiptData? data;

  /// UI navigation signal
  final int backHomeRequestId;

  const GuestPurchasePlanReceiptState({
    required this.status,
    required this.data,
    required this.backHomeRequestId,
  });

  factory GuestPurchasePlanReceiptState.initial() {
    return const GuestPurchasePlanReceiptState(
      status: GuestPurchasePlanReceiptStatus.initial,
      data: null,
      backHomeRequestId: 0,
    );
  }

  GuestPurchasePlanReceiptState copyWith({
    GuestPurchasePlanReceiptStatus? status,
    GuestPurchasePlanReceiptData? data,
    int? backHomeRequestId,
  }) {
    return GuestPurchasePlanReceiptState(
      status: status ?? this.status,
      data: data ?? this.data,
      backHomeRequestId: backHomeRequestId ?? this.backHomeRequestId,
    );
  }

  @override
  List<Object?> get props => [status, data, backHomeRequestId];
}
