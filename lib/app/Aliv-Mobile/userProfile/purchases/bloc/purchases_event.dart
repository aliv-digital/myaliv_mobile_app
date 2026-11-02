import 'package:equatable/equatable.dart';
import '../model/purchases_models.dart';

abstract class PurchasesEvent extends Equatable {
  const PurchasesEvent();

  @override
  List<Object?> get props => [];
}

class PurchasesStarted extends PurchasesEvent {
  final bool isPrepaid;

  const PurchasesStarted({required this.isPrepaid});

  @override
  List<Object?> get props => [isPrepaid];
}

class PurchasesItemTapped extends PurchasesEvent {
  final PurchasesAction action;
  const PurchasesItemTapped(this.action);

  @override
  List<Object?> get props => [action];
}

/// Navigation one-shot consume করার জন্য
class PurchasesNavigationConsumed extends PurchasesEvent {
  const PurchasesNavigationConsumed();
}
