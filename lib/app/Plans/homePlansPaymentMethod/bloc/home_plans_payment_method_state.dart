import 'package:equatable/equatable.dart';
import '../model/home_plans_payment_method_models.dart';

enum HomePlansPaymentMethodStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

enum HomePlansPaymentMethodNavTarget { none, addCard, wallet, paid }

class HomePlansPaymentMethodState extends Equatable {
  final HomePlansPaymentMethodStatus status;
  final String? errorMessage;
  final HomePlansSubscriberType subscriberType;
  final String phoneNumber;

  final List<HomePlansSavedPaymentMethod> methods;
  final String? selectedMethodId;

  final double amount;
  final String vatNote;
  final List<HomePlansPaymentSelectedItem> selectedItems;

  final HomePlansPaymentMethodNavTarget navTarget;
  final String? walletWarningMessage;
  final int walletWarningRequestId;

  const HomePlansPaymentMethodState({
    required this.status,
    required this.errorMessage,
    required this.subscriberType,
    required this.phoneNumber,
    required this.methods,
    required this.selectedMethodId,
    required this.amount,
    required this.vatNote,
    required this.selectedItems,
    required this.navTarget,
    required this.walletWarningMessage,
    required this.walletWarningRequestId,
  });

  factory HomePlansPaymentMethodState.initial() {
    return const HomePlansPaymentMethodState(
      status: HomePlansPaymentMethodStatus.initial,
      errorMessage: null,
      subscriberType: HomePlansSubscriberType.postpaid,
      phoneNumber: '',
      methods: [],
      selectedMethodId: null,
      amount: 5.00,
      vatNote: 'no vat applied',
      selectedItems: [],
      navTarget: HomePlansPaymentMethodNavTarget.none,
      walletWarningMessage: null,
      walletWarningRequestId: 0,
    );
  }

  String get amountText => r'$ ' + amount.toStringAsFixed(2);

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
    String? phoneNumber,
    List<HomePlansSavedPaymentMethod>? methods,
    String? selectedMethodId,
    double? amount,
    String? vatNote,
    List<HomePlansPaymentSelectedItem>? selectedItems,
    HomePlansPaymentMethodNavTarget? navTarget,
    String? walletWarningMessage,
    int? walletWarningRequestId,
  }) {
    return HomePlansPaymentMethodState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      subscriberType: subscriberType ?? this.subscriberType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      amount: amount ?? this.amount,
      vatNote: vatNote ?? this.vatNote,
      selectedItems: selectedItems ?? this.selectedItems,
      navTarget: navTarget ?? this.navTarget,
      walletWarningMessage: walletWarningMessage ?? this.walletWarningMessage,
      walletWarningRequestId:
          walletWarningRequestId ?? this.walletWarningRequestId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        subscriberType,
        phoneNumber,
        methods,
        selectedMethodId,
        amount,
        vatNote,
        selectedItems,
        navTarget,
        walletWarningMessage,
        walletWarningRequestId,
      ];
}
