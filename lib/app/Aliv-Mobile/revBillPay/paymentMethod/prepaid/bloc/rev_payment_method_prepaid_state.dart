import 'package:equatable/equatable.dart';
import '../model/rev_payment_method_prepaid_models.dart';

enum RevPaymentMethodPrepaidStatus { initial, loading, ready, submitting, success, failure }
enum RevPaymentMethodNavTarget { none, addCard, paid }

class RevPaymentMethodPrepaidState extends Equatable {
  final RevPaymentMethodPrepaidStatus status;
  final String? errorMessage;

  final List<RevSavedPaymentMethod> methods;
  final String? selectedMethodId;

  final double amount;
  final String vatNote;

  final RevPaymentMethodNavTarget navTarget;

  const RevPaymentMethodPrepaidState({
    required this.status,
    required this.errorMessage,
    required this.methods,
    required this.selectedMethodId,
    required this.amount,
    required this.vatNote,
    required this.navTarget,
  });

  factory RevPaymentMethodPrepaidState.initial() {
    return const RevPaymentMethodPrepaidState(
      status: RevPaymentMethodPrepaidStatus.initial,
      errorMessage: null,
      methods: [],
      selectedMethodId: null,
      amount: 200.00,
      vatNote: 'no vat applied',
      navTarget: RevPaymentMethodNavTarget.none,
    );
  }

  String get amountText => r'$ ' + amount.toStringAsFixed(2);

  bool get isPayNowEnabled =>
      selectedMethodId != null && status != RevPaymentMethodPrepaidStatus.submitting;

  RevPaymentMethodPrepaidState copyWith({
    RevPaymentMethodPrepaidStatus? status,
    String? errorMessage,
    List<RevSavedPaymentMethod>? methods,
    String? selectedMethodId,
    double? amount,
    String? vatNote,
    RevPaymentMethodNavTarget? navTarget,
  }) {
    return RevPaymentMethodPrepaidState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      amount: amount ?? this.amount,
      vatNote: vatNote ?? this.vatNote,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    methods,
    selectedMethodId,
    amount,
    vatNote,
    navTarget,
  ];
}
