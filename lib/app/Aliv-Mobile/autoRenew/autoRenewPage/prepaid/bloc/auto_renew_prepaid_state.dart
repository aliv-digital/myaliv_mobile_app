import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import '../models/auto_renew_prepaid_models.dart';

enum AutoRenewLoadStatus { initial, loading, ready, failure }

enum AutoRenewNavTarget { none, addCard, wallet, home, proceed }

class AutoRenewPrepaidState extends Equatable {
  final AutoRenewLoadStatus loadStatus;
  final List<AutoRenewPaymentMethod> methods;
  final String? selectedMethodId;
  final SavedCardModel? selectedCard;
  final double walletBalance;
  final double walletPaymentAmount;

  final AutoRenewNavTarget navTarget;
  final String? errorMessage;
  final bool savingSelection;

  const AutoRenewPrepaidState({
    required this.loadStatus,
    required this.methods,
    required this.selectedMethodId,
    required this.selectedCard,
    required this.walletBalance,
    required this.walletPaymentAmount,
    required this.navTarget,
    required this.errorMessage,
    required this.savingSelection,
  });

  factory AutoRenewPrepaidState.initial() => const AutoRenewPrepaidState(
        loadStatus: AutoRenewLoadStatus.initial,
        methods: [],
        selectedMethodId: null,
        selectedCard: null,
        walletBalance: 129.00,
        walletPaymentAmount: 75.00,
        navTarget: AutoRenewNavTarget.none,
        errorMessage: null,
        savingSelection: false,
      );

  bool get canProceed => selectedMethodId != null && !savingSelection;
  String get walletBalanceText => '\$${walletBalance.toStringAsFixed(2)}';
  String get walletPaymentAmountText =>
      '\$ ${walletPaymentAmount.toStringAsFixed(2)}';

  AutoRenewPrepaidState copyWith({
    AutoRenewLoadStatus? loadStatus,
    List<AutoRenewPaymentMethod>? methods,
    String? selectedMethodId,
    SavedCardModel? selectedCard,
    double? walletBalance,
    double? walletPaymentAmount,
    AutoRenewNavTarget? navTarget,
    String? errorMessage,
    bool? savingSelection,
    bool clearError = false,
    bool clearSelectedCard = false,
  }) {
    return AutoRenewPrepaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      selectedCard:
          clearSelectedCard ? null : (selectedCard ?? this.selectedCard),
      walletBalance: walletBalance ?? this.walletBalance,
      walletPaymentAmount: walletPaymentAmount ?? this.walletPaymentAmount,
      navTarget: navTarget ?? this.navTarget,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      savingSelection: savingSelection ?? this.savingSelection,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        methods,
        selectedMethodId,
        selectedCard,
        walletBalance,
        walletPaymentAmount,
        navTarget,
        errorMessage,
        savingSelection,
      ];
}
