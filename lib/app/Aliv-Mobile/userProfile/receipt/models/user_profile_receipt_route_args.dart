import 'package:equatable/equatable.dart';

class UserProfileReceiptRouteArgs extends Equatable {
  final double amount;
  final String? phoneNumber;
  final String topUpType;
  final String paymentMethod;
  final DateTime? createdAt;
  final String title;
  final String message;
  final String? recipientPhone;

  const UserProfileReceiptRouteArgs({
    required this.amount,
    this.phoneNumber,
    this.topUpType = 'prepaid',
    this.paymentMethod = 'credit card',
    this.createdAt,
    this.title = 'Payment Success!',
    this.message =
        'It will take a few moments for the top-up to appear on the account.',
    this.recipientPhone,
  });

  factory UserProfileReceiptRouteArgs.fromQuery(Map<String, String> query) {
    final amount = double.tryParse(query['amount'] ?? '') ?? 0;

    return UserProfileReceiptRouteArgs(
      amount: amount,
      phoneNumber: _emptyToNull(query['phoneNumber']),
      topUpType: _valueOrDefault(query['topUpType'], 'prepaid'),
      paymentMethod: _valueOrDefault(query['paymentMethod'], 'credit card'),
      title: _valueOrDefault(query['title'], 'Payment Success!'),
      message: _valueOrDefault(
        query['message'],
        'It will take a few moments for the top-up to appear on the account.',
      ),
    );
  }

  static String? _emptyToNull(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static String _valueOrDefault(String? value, String fallback) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  @override
  List<Object?> get props => [
    amount,
    phoneNumber,
    topUpType,
    paymentMethod,
    createdAt,
    title,
    message,
  ];
}
