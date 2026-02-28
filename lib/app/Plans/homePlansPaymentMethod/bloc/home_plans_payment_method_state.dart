import 'package:equatable/equatable.dart';
import '../model/home_plans_payment_method_models.dart';

enum HomePlansPaymentMethodStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure
}

enum HomePlansPaymentMethodNavTarget { none, addCard, wallet, paid }

class HomePlansPaymentMethodState extends Equatable {
  final HomePlansPaymentMethodStatus status;
  final String? errorMessage;
  final HomePlansSubscriberType subscriberType;
  final double walletBalance;

  final List<HomePlansSavedPaymentMethod> methods;
  final String? selectedMethodId;

  final double amount;
  final String vatNote;

  final HomePlansPaymentMethodNavTarget navTarget;

  const HomePlansPaymentMethodState({
    required this.status,
    required this.errorMessage,
    required this.subscriberType,
    required this.walletBalance,
    required this.methods,
    required this.selectedMethodId,
    required this.amount,
    required this.vatNote,
    required this.navTarget,
  });

  factory HomePlansPaymentMethodState.initial() {
    return const HomePlansPaymentMethodState(
      status: HomePlansPaymentMethodStatus.initial,
      errorMessage: null,
      subscriberType: HomePlansSubscriberType.postpaid,
      walletBalance: 0.0,
      methods: [],
      selectedMethodId: null,
      amount: 5.00,
      vatNote: 'no vat applied',
      navTarget: HomePlansPaymentMethodNavTarget.none,
    );
  }

  String get amountText => r'$ ' + amount.toStringAsFixed(2);
  String get walletBalanceText => r'$' + walletBalance.toStringAsFixed(2);

  bool get isPrepaidUser {
    return subscriberType == HomePlansSubscriberType.prepaid;
  }

  bool get isPayNowEnabled {
    return selectedMethodId != null &&
        status != HomePlansPaymentMethodStatus.submitting;
  }

  HomePlansPaymentMethodState copyWith({
    HomePlansPaymentMethodStatus? status,
    String? errorMessage,
    HomePlansSubscriberType? subscriberType,
    double? walletBalance,
    List<HomePlansSavedPaymentMethod>? methods,
    String? selectedMethodId,
    double? amount,
    String? vatNote,
    HomePlansPaymentMethodNavTarget? navTarget,
  }) {
    return HomePlansPaymentMethodState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      subscriberType: subscriberType ?? this.subscriberType,
      walletBalance: walletBalance ?? this.walletBalance,
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
        subscriberType,
        walletBalance,
        methods,
        selectedMethodId,
        amount,
        vatNote,
        navTarget,
      ];
}
