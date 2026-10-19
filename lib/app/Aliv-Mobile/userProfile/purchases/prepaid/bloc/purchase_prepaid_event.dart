import 'package:equatable/equatable.dart';
import '../model/purchase_prepaid_models.dart';

abstract class PurchasePrepaidEvent extends Equatable {
  const PurchasePrepaidEvent();

  @override
  List<Object?> get props => [];
}

class PurchasePrepaidStarted extends PurchasePrepaidEvent {
  final bool isPrepaid;

  const PurchasePrepaidStarted({required this.isPrepaid});

  @override
  List<Object?> get props => [isPrepaid];
}

class PurchasePrepaidItemTapped extends PurchasePrepaidEvent {
  final PurchasePrepaidAction action;
  const PurchasePrepaidItemTapped(this.action);

  @override
  List<Object?> get props => [action];
}

/// Navigation one-shot consume করার জন্য
class PurchasePrepaidNavigationConsumed extends PurchasePrepaidEvent {
  const PurchasePrepaidNavigationConsumed();
}
