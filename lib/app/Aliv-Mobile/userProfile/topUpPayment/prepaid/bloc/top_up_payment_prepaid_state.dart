import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/models/payment_summary.dart';

enum TopUpPaymentStatus { initial, loading, ready, paying, success, failure }

enum TopUpPaymentMode { card, payWithCard }

/// One-shot post-payment navigation target. Set on success, consumed by the
/// view via [PaymentNavConsumed] once the receipt route has been pushed.
enum TopUpPaymentNavTarget { none, paid }

class TopUpPaymentPrepaidState extends Equatable {
  final TopUpPaymentStatus status;
  final TopUpPaymentMode paymentMode;
  final String? selectedMethodId;
  final PaymentSummary summary;
  final String? errorMessage;
  final TopUpPaymentNavTarget navTarget;

  const TopUpPaymentPrepaidState({
    required this.status,
    required this.paymentMode,
    required this.selectedMethodId,
    required this.summary,
    required this.errorMessage,
    required this.navTarget,
  });

  factory TopUpPaymentPrepaidState.initial() => const TopUpPaymentPrepaidState(
    status: TopUpPaymentStatus.initial,
    paymentMode: TopUpPaymentMode.card,
    selectedMethodId: null,
    summary: PaymentSummary(total: 0, vatInclusive: true),
    errorMessage: null,
    navTarget: TopUpPaymentNavTarget.none,
  );

  bool get isBusy =>
      status == TopUpPaymentStatus.loading ||
      status == TopUpPaymentStatus.paying;

  bool get hasMethodSelected =>
      paymentMode == TopUpPaymentMode.payWithCard ||
      (selectedMethodId != null && selectedMethodId!.isNotEmpty);

  TopUpPaymentPrepaidState copyWith({
    TopUpPaymentStatus? status,
    TopUpPaymentMode? paymentMode,
    String? selectedMethodId,
    PaymentSummary? summary,
    String? errorMessage,
    TopUpPaymentNavTarget? navTarget,
    bool clearSelection = false,
    bool clearErrorMessage = false,
  }) {
    return TopUpPaymentPrepaidState(
      status: status ?? this.status,
      paymentMode: paymentMode ?? this.paymentMode,
      selectedMethodId: clearSelection
          ? null
          : (selectedMethodId ?? this.selectedMethodId),
      summary: summary ?? this.summary,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
    status,
    paymentMode,
    selectedMethodId,
    summary,
    errorMessage,
    navTarget,
  ];
}
