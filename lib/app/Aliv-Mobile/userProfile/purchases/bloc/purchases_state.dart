import 'package:equatable/equatable.dart';
import '../model/purchases_models.dart';

enum PurchasesLoadStatus { initial, loading, ready, failure }

class PurchasesState extends Equatable {
  final PurchasesLoadStatus status;
  final List<PurchasesMenuItem> items;
  final String? errorMessage;

  /// one-shot navigation
  final PurchasesAction? navigateTo;

  const PurchasesState({
    required this.status,
    required this.items,
    required this.errorMessage,
    required this.navigateTo,
  });

  factory PurchasesState.initial() => const PurchasesState(
    status: PurchasesLoadStatus.initial,
    items: [],
    errorMessage: null,
    navigateTo: null,
  );

  PurchasesState copyWith({
    PurchasesLoadStatus? status,
    List<PurchasesMenuItem>? items,
    String? errorMessage,
    bool clearError = false,
    PurchasesAction? navigateTo,
    bool clearNavigation = false,
  }) {
    return PurchasesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navigateTo: clearNavigation ? null : (navigateTo ?? this.navigateTo),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, navigateTo];
}
