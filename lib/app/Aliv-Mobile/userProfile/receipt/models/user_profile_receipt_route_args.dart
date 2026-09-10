import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

import 'user_profile_receipt_variant.dart';

class UserProfileReceiptRouteArgs extends Equatable {
  static const String topUpPendingMessage =
      'It will take a few moments for the top-up to appear on the account.';
  static const String postpaidPaymentPendingMessage =
      'It will take a few moments for the payment to appear on the account.';

  final double amount;
  final String? phoneNumber;
  final String topUpType;
  final String paymentMethod;
  final DateTime? createdAt;
  final String title;
  final String? message;
  final String? recipientPhone;
  final UserProfileReceiptVariant variant;

  /// If present, the receipt shows the "save credit card" button; on tap
  /// it saves via [SavedCardsCubit.addCard]. Null for wallet / saved-card
  /// payments where there is nothing new to save.
  final NewCardDetails? cardToSave;

  /// Order ID from a completed 3DS payment ([PaymentSuccess.orderId]).
  /// When set, the receipt shows the "save credit card" bottom sheet that
  /// calls `CreditCard/savenew` instead of the direct [cardToSave] path.
  final String? orderId;

  const UserProfileReceiptRouteArgs({
    required this.amount,
    this.phoneNumber,
    this.topUpType = 'prepaid',
    this.paymentMethod = 'credit card',
    this.createdAt,
    this.title = 'Payment Success!',
    this.message,
    this.recipientPhone,
    this.variant = UserProfileReceiptVariant.standard,
    this.cardToSave,
    this.orderId,
  });

  bool get isPostpaidPayment => topUpType.trim().toLowerCase() == 'postpaid';

  String get receiptMessage =>
      message ??
      (isPostpaidPayment ? postpaidPaymentPendingMessage : topUpPendingMessage);

  String get receiptTypeLabel => isPostpaidPayment ? 'service' : 'top-up';

  factory UserProfileReceiptRouteArgs.fromQuery(Map<String, String> query) {
    final amount = double.tryParse(query['amount'] ?? '') ?? 0;

    return UserProfileReceiptRouteArgs(
      amount: amount,
      phoneNumber: _emptyToNull(query['phoneNumber']),
      topUpType: _valueOrDefault(query['topUpType'], 'prepaid'),
      paymentMethod: _valueOrDefault(query['paymentMethod'], 'credit card'),
      title: _valueOrDefault(query['title'], 'Payment Success!'),
      message: _emptyToNull(query['message']),
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
    variant,
  ];
}
