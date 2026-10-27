import 'package:equatable/equatable.dart';

/// Response for GET /device/can-send-data-share/{senderMsisdn}.
///
/// `Reason` is a server-defined status string. Known values:
/// - `"SenderEligible"` — proceed with the flow; `AvailablePlans` is populated.
/// Anything else is treated as "not eligible" by [isSenderEligible].
class CanSendDataShareResponse extends Equatable {
  const CanSendDataShareResponse({
    required this.reason,
    required this.availablePlans,
  });

  final String reason;
  final List<AvailableGiftPlan> availablePlans;

  bool get isSenderEligible => reason.toLowerCase() == 'sendereligible';

  factory CanSendDataShareResponse.fromJson(Map<String, dynamic> json) {
    final rawPlans = json['AvailablePlans'];
    final plans = <AvailableGiftPlan>[];
    if (rawPlans is List) {
      for (final entry in rawPlans) {
        if (entry is Map<String, dynamic>) {
          plans.add(AvailableGiftPlan.fromJson(entry));
        }
      }
    }
    return CanSendDataShareResponse(
      reason: (json['Reason'] as String?) ?? '',
      availablePlans: plans,
    );
  }

  @override
  List<Object?> get props => [reason, availablePlans];
}

/// A single catalog entry inside `AvailablePlans`.
/// Only the fields the UI / submit flow needs are hydrated — the rest of the
/// `plan` payload (frequency, capabilities, ...) is ignored.
class AvailableGiftPlan extends Equatable {
  const AvailableGiftPlan({
    required this.dataSharePlanId,
    required this.dataShareId,
    required this.planId,
    required this.amountGb,
    required this.planName,
  });

  final int dataSharePlanId;
  final int dataShareId;
  final int planId;
  final double amountGb;
  final String planName;

  factory AvailableGiftPlan.fromJson(Map<String, dynamic> json) {
    final planObj = json['plan'];
    final planName = planObj is Map<String, dynamic>
        ? (planObj['PlanName'] as String?) ?? ''
        : '';

    return AvailableGiftPlan(
      dataSharePlanId: _asInt(json['DataSharePlanID']),
      dataShareId: _asInt(json['DataShareID']),
      planId: _asInt(json['PlanID']),
      amountGb: _asDouble(json['Amount']),
      planName: planName,
    );
  }

  @override
  List<Object?> get props => [
    dataSharePlanId,
    dataShareId,
    planId,
    amountGb,
    planName,
  ];
}

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _asDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
