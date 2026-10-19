import 'package:equatable/equatable.dart';
import '../model/purchase_prepaid_models.dart';

enum PurchasePrepaidLoadStatus { initial, loading, ready, failure }

class PurchasePrepaidState extends Equatable {
  final PurchasePrepaidLoadStatus status;
  final List<PurchasePrepaidMenuItem> items;
  final String? errorMessage;

  /// one-shot navigation
  final PurchasePrepaidAction? navigateTo;

  const PurchasePrepaidState({
    required this.status,
    required this.items,
    required this.errorMessage,
    required this.navigateTo,
  });

  factory PurchasePrepaidState.initial() => const PurchasePrepaidState(
    status: PurchasePrepaidLoadStatus.initial,
    items: [],
    errorMessage: null,
    navigateTo: null,
  );

  PurchasePrepaidState copyWith({
    PurchasePrepaidLoadStatus? status,
    List<PurchasePrepaidMenuItem>? items,
    String? errorMessage,
    bool clearError = false,
    PurchasePrepaidAction? navigateTo,
    bool clearNavigation = false,
  }) {
    return PurchasePrepaidState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navigateTo: clearNavigation ? null : (navigateTo ?? this.navigateTo),
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage, navigateTo];
}
