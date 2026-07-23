import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';

/// Arguments passed into the MiFi alternate contact screen.
///
/// The screen collects an alt phone number + offers opt-in, then forwards
/// to `HomePlanConfirmationScreen` carrying the same plan context.
class MifiAltContactRouteArgs extends Equatable {
  final BasePlanModel? selectedApiPlan;
  final HomePlanModel fallbackPlan;

  /// `true` → plan should start immediately, `false` → future plan.
  final bool forceNow;

  /// Active plan end date to use as the future plan's start date.
  final String futurePlanStartDate;

  /// Pre-fills the phone field when the account already has an alt number
  /// on file. The user can still edit before continuing.
  final String prefilledAltNumber;

  const MifiAltContactRouteArgs({
    required this.fallbackPlan,
    this.selectedApiPlan,
    this.forceNow = true,
    this.futurePlanStartDate = '',
    this.prefilledAltNumber = '',
  });

  /// `true` when the user tapped "future plan", `false` for "activate now".
  bool get isFuture => !forceNow;

  @override
  List<Object?> get props => [
        selectedApiPlan,
        fallbackPlan,
        forceNow,
        futurePlanStartDate,
        prefilledAltNumber,
      ];
}
