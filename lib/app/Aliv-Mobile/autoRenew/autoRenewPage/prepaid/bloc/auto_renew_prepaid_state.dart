import 'package:equatable/equatable.dart';
import '../models/auto_renew_prepaid_models.dart';

enum AutoRenewLoadStatus { initial, loading, ready, failure }

enum AutoRenewNavTarget { none, addCard, home, proceed }

class AutoRenewPrepaidState extends Equatable {
  final AutoRenewLoadStatus loadStatus;
  final List<AutoRenewPaymentMethod> methods;
  final String? selectedMethodId;

  final AutoRenewNavTarget navTarget;
  final String? errorMessage;
  final bool savingSelection;

  const AutoRenewPrepaidState({
    required this.loadStatus,
    required this.methods,
    required this.selectedMethodId,
    required this.navTarget,
    required this.errorMessage,
    required this.savingSelection,
  });

  factory AutoRenewPrepaidState.initial() => const AutoRenewPrepaidState(
    loadStatus: AutoRenewLoadStatus.initial,
    methods: [],
    selectedMethodId: null,
    navTarget: AutoRenewNavTarget.none,
    errorMessage: null,
    savingSelection: false,
  );

  bool get canProceed => selectedMethodId != null && !savingSelection;

  AutoRenewPrepaidState copyWith({
    AutoRenewLoadStatus? loadStatus,
    List<AutoRenewPaymentMethod>? methods,
    String? selectedMethodId,
    AutoRenewNavTarget? navTarget,
    String? errorMessage,
    bool? savingSelection,
    bool clearError = false,
  }) {
    return AutoRenewPrepaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
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
    navTarget,
    errorMessage,
    savingSelection,
  ];
}
