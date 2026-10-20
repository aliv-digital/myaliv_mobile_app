import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_frequency.dart';

/// Shared duration math for prepaid optimistic plan injection and the
/// guest "new active plan will be" red card.
///
/// Returns the estimated plan end date based on billing [frequency]:
///   D → +1 day · W → +7 days · M → +1 calendar month
/// Returns `null` for frequencies that don't map to a fixed duration
/// (roaming, mifi, liberty-global, etc.) so the UI can render a `--/--`
/// placeholder until the real data arrives.
class PlanFrequencyEstimator {
  const PlanFrequencyEstimator._();

  static DateTime? estimateEndDate(DateTime start, PlanFrequency? frequency) {
    switch (frequency) {
      case PlanFrequency.daily:
        return start.add(const Duration(days: 1));
      case PlanFrequency.weekly:
        return start.add(const Duration(days: 7));
      case PlanFrequency.monthly:
        return DateTime.utc(
          start.year,
          start.month + 1,
          start.day,
          start.hour,
          start.minute,
          start.second,
        );
      case null:
        return null;
    }
  }
}
