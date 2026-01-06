import 'package:equatable/equatable.dart';

enum GuestPayBillReceiptStatus { initial }

class GuestPayBillReceiptData extends Equatable {
  final String leftType; // top up
  final String rightType; // prepaid
  final String dateText; // Mar 22, 2023
  final String timeText; // 07:30 am
  final String phoneNumber; // 242-801-1616
  final String paymentMethod; // credit card
  final double amount; // 15.00

  const GuestPayBillReceiptData({
    required this.leftType,
    required this.rightType,
    required this.dateText,
    required this.timeText,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.amount,
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
  ];
}

class GuestPayBillReceiptState extends Equatable {
  final GuestPayBillReceiptStatus status;
  final GuestPayBillReceiptData? data;

  /// UI navigation signal
  final int backHomeRequestId;

  const GuestPayBillReceiptState({
    required this.status,
    required this.data,
    required this.backHomeRequestId,
  });

  factory GuestPayBillReceiptState.initial() {
    return const GuestPayBillReceiptState(
      status: GuestPayBillReceiptStatus.initial,
      data: null,
      backHomeRequestId: 0,
    );
  }

  GuestPayBillReceiptState copyWith({
    GuestPayBillReceiptStatus? status,
    GuestPayBillReceiptData? data,
    int? backHomeRequestId,
  }) {
    return GuestPayBillReceiptState(
      status: status ?? this.status,
      data: data ?? this.data,
      backHomeRequestId: backHomeRequestId ?? this.backHomeRequestId,
    );
  }

  @override
  List<Object?> get props => [status, data, backHomeRequestId];
}
