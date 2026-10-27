import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/can_send_data_share_response.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';

/// Converts the raw `can-send-data-share` response into the UI-facing
/// [GiftAmountOption] list and the sender's total giftable budget.
///
/// Mirrors `BestPlanParserService` (`lib/app/Home/best-plans/repository/services/`)
/// so the repository can stay thin.
class GiftDataParserService {
  /// Maps every entry in `AvailablePlans` to a selectable chip. Options whose
  /// `PlanName` yields an empty label fall back to a GB-derived label so the
  /// chip never renders blank.
  List<GiftAmountOption> parseOptions(CanSendDataShareResponse response) {
    final out = <GiftAmountOption>[];
    for (final plan in response.availablePlans) {
      final label = labelFromPlanName(plan.planName);
      out.add(
        GiftAmountOption(
          planId: plan.planId,
          dataSharePlanId: plan.dataSharePlanId,
          amountGb: plan.amountGb,
          label: label.isNotEmpty ? label : formatGb(plan.amountGb),
        ),
      );
    }
    return out;
  }

  /// Normalises a backend `PlanName` into the lowercase chip label:
  ///   "gift 500 MB" → "500 mb"
  ///   "gift 1 GB"   → "1 gb"
  /// Returns an empty string if the input is blank (caller falls back).
  String labelFromPlanName(String planName) {
    final trimmed = planName.trim();
    if (trimmed.isEmpty) return '';
    final stripped = trimmed.replaceFirst(
      RegExp(r'^gift\s+', caseSensitive: false),
      '',
    );
    return stripped.toLowerCase();
  }
}
