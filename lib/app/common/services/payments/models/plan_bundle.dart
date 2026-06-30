import 'package:equatable/equatable.dart';

/// Plan ids classified by role, ready to be sent as the `Bundle` block of the
/// `change-bundle` API. At least one list must be non-empty.
class PlanBundle extends Equatable {
  final List<int> primaryPlans;
  final List<int> secondaryPlans;
  final List<int> standalonePlans;

  const PlanBundle({
    this.primaryPlans = const <int>[],
    this.secondaryPlans = const <int>[],
    this.standalonePlans = const <int>[],
  });

  bool get isEmpty =>
      primaryPlans.isEmpty &&
      secondaryPlans.isEmpty &&
      standalonePlans.isEmpty;

  @override
  List<Object?> get props => [primaryPlans, secondaryPlans, standalonePlans];
}
