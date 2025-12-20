import 'package:equatable/equatable.dart';

enum GuestTopUpReceiptStatus { initial }

class GuestTopUpReceiptData extends Equatable {
  final String leftType; // top up
  final String rightType; // prepaid
  final String dateText; // Mar 22, 2023
  final String timeText; // 07:30 am
  final String phoneNumber; // 242-801-1616
  final String paymentMethod; // credit card
  final double amount; // 15.00

  const GuestTopUpReceiptData({
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

class GuestTopUpReceiptState extends Equatable {
  final GuestTopUpReceiptStatus status;
  final GuestTopUpReceiptData? data;

  /// UI navigation signal
  final int backHomeRequestId;

  const GuestTopUpReceiptState({
    required this.status,
    required this.data,
    required this.backHomeRequestId,
  });

  factory GuestTopUpReceiptState.initial() {
    return const GuestTopUpReceiptState(
      status: GuestTopUpReceiptStatus.initial,
      data: null,
      backHomeRequestId: 0,
    );
  }

  GuestTopUpReceiptState copyWith({
    GuestTopUpReceiptStatus? status,
    GuestTopUpReceiptData? data,
    int? backHomeRequestId,
  }) {
    return GuestTopUpReceiptState(
      status: status ?? this.status,
      data: data ?? this.data,
      backHomeRequestId: backHomeRequestId ?? this.backHomeRequestId,
    );
  }

  @override
  List<Object?> get props => [status, data, backHomeRequestId];
}
