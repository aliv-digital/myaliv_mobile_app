import 'package:equatable/equatable.dart';
import '../model/guest_payment_method_prepaid_models.dart';

enum GuestPaymentMethodPrepaidStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure
}

enum GuestPaymentMethodNavTarget { none, addCard, paid }

class GuestPaymentMethodPrepaidState extends Equatable {
  final GuestPaymentMethodPrepaidStatus status;
  final String? errorMessage;

  final List<GuestSavedPaymentMethod> methods;
  final String? selectedMethodId;

  final double amount;
  final String vatNote;

  final GuestPaymentMethodNavTarget navTarget;

  const GuestPaymentMethodPrepaidState({
    required this.status,
    required this.errorMessage,
    required this.methods,
    required this.selectedMethodId,
    required this.amount,
    required this.vatNote,
    required this.navTarget,
  });

  factory GuestPaymentMethodPrepaidState.initial() {
    return const GuestPaymentMethodPrepaidState(
      status: GuestPaymentMethodPrepaidStatus.initial,
      errorMessage: null,
      methods: [],
      selectedMethodId: null,
      amount: 200.00,
      vatNote: 'no vat applied',
      navTarget: GuestPaymentMethodNavTarget.none,
    );
  }

  String get amountText => r'$ ' + amount.toStringAsFixed(2);

  bool get isPayNowEnabled =>
      selectedMethodId != null &&
      status != GuestPaymentMethodPrepaidStatus.submitting;

  GuestPaymentMethodPrepaidState copyWith({
    GuestPaymentMethodPrepaidStatus? status,
    String? errorMessage,
    List<GuestSavedPaymentMethod>? methods,
    String? selectedMethodId,
    double? amount,
    String? vatNote,
    GuestPaymentMethodNavTarget? navTarget,
  }) {
    return GuestPaymentMethodPrepaidState(
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
