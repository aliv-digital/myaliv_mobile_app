import 'package:equatable/equatable.dart';

enum HomePlanPurchaseReceiptStatus { initial }

///  Dynamic receipt row model
class HomePlanPurchaseReceiptDetailItem extends Equatable {
  final String label;
  final String value;
  final bool valueBold;

  const HomePlanPurchaseReceiptDetailItem({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  List<Object?> get props => [label, value, valueBold];
}

class HomePlanPurchaseReceiptData extends Equatable {
  final String leftType; // top up
  final String rightType; // prepaid
  final String dateText; // Mar 22, 2023
  final String timeText; // 07:30 am
  final String phoneNumber; // 242-801-1616
  final String paymentMethod; // credit card
  final double amount; // 15.00

  /// Dynamic list of rows for HomePlanPurchaseReceiptDetailRow()
  final List<HomePlanPurchaseReceiptDetailItem> details;

  const HomePlanPurchaseReceiptData({
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

class HomePlanPurchaseReceiptState extends Equatable {
  final HomePlanPurchaseReceiptStatus status;
  final HomePlanPurchaseReceiptData? data;

  /// UI navigation signal
  final int backHomeRequestId;

  const HomePlanPurchaseReceiptState({
    required this.status,
    required this.data,
    required this.backHomeRequestId,
  });

  factory HomePlanPurchaseReceiptState.initial() {
    return const HomePlanPurchaseReceiptState(
      status: HomePlanPurchaseReceiptStatus.initial,
      data: null,
      backHomeRequestId: 0,
    );
  }

  HomePlanPurchaseReceiptState copyWith({
    HomePlanPurchaseReceiptStatus? status,
    HomePlanPurchaseReceiptData? data,
    int? backHomeRequestId,
  }) {
    return HomePlanPurchaseReceiptState(
      status: status ?? this.status,
      data: data ?? this.data,
      backHomeRequestId: backHomeRequestId ?? this.backHomeRequestId,
    );
  }

  @override
  List<Object?> get props => [status, data, backHomeRequestId];
}
