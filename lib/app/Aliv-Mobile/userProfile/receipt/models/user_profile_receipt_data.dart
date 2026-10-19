import 'package:equatable/equatable.dart';

import 'user_profile_receipt_variant.dart';

class UserProfileReceiptData extends Equatable {
  final String typeLabel;
  final String topUpType;
  final String dateText;
  final String timeText;
  final String phoneNumber;
  final String paymentMethod;
  final double amount;
  final String title;
  final String message;
  final UserProfileReceiptVariant variant;

  const UserProfileReceiptData({
    required this.typeLabel,
    required this.topUpType,
    required this.dateText,
    required this.timeText,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.amount,
    required this.title,
    required this.message,
    this.variant = UserProfileReceiptVariant.standard,
  });

  @override
  List<Object?> get props => [
    typeLabel,
    topUpType,
    dateText,
    timeText,
    phoneNumber,
    paymentMethod,
    amount,
    title,
    message,
    variant,
  ];
}
