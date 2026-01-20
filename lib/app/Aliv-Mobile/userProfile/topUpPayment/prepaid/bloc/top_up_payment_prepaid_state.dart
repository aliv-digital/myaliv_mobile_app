import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/models/payment_method.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/models/payment_summary.dart';


enum TopUpPaymentStatus { initial, loading, ready, paying, success, failure }

class TopUpPaymentPrepaidState extends Equatable {
  final TopUpPaymentStatus status;
  final List<PaymentMethod> methods;
  final String? selectedMethodId;
  final PaymentSummary summary;
  final String? errorMessage;

  const TopUpPaymentPrepaidState({
    required this.status,
    required this.methods,
    required this.selectedMethodId,
    required this.summary,
    required this.errorMessage,
  });

  factory TopUpPaymentPrepaidState.initial() => const TopUpPaymentPrepaidState(
    status: TopUpPaymentStatus.initial,
    methods: [],
    selectedMethodId: null,
    summary: PaymentSummary(total: 0, vatInclusive: true),
    errorMessage: null,
  );

  bool get isBusy => status == TopUpPaymentStatus.loading || status == TopUpPaymentStatus.paying;

  TopUpPaymentPrepaidState copyWith({
    TopUpPaymentStatus? status,
    List<PaymentMethod>? methods,
    String? selectedMethodId,
    PaymentSummary? summary,
    String? errorMessage,
  }) {
    return TopUpPaymentPrepaidState(
      status: status ?? this.status,
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, methods, selectedMethodId, summary, errorMessage];
}
