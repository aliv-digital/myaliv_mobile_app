import 'package:equatable/equatable.dart';

/// A single selectable amount shown in the "choose gift amount" row.
/// Hydrated from `AvailablePlans` by `GiftDataParserService`:
/// - [label] comes from the backend `PlanName` ("gift 500 MB" → "500 mb").
/// - [amountGb] is the raw gift size (used for cap checks + remaining math).
/// - [planId] / [dataSharePlanId] are forwarded to the submit API.
class GiftAmountOption extends Equatable {
  const GiftAmountOption({
    required this.planId,
    required this.dataSharePlanId,
    required this.amountGb,
    required this.label,
  });

  final int planId;
  final int dataSharePlanId;
  final double amountGb;
  final String label;

  /// MB representation used for cap-check arithmetic (1 GB = 1000 MB).
  int get amountMb => (amountGb * 1000).round();

  @override
  List<Object?> get props => [planId, dataSharePlanId, amountGb, label];
}

/// Receipt payload for the success screen.
class GiftDataReceiptData extends Equatable {
  const GiftDataReceiptData({
    required this.recipientNumber,
    required this.orderReference,
    required this.dateText,
    required this.timeText,
    required this.totalDataLabel,
    required this.remainingDataLabel,
    required this.dataGiftedLabel,
  });

  final String recipientNumber;
  final String orderReference;
  final String dateText;
  final String timeText;
  final String totalDataLabel;
  final String remainingDataLabel;
  final String dataGiftedLabel;

  @override
  List<Object?> get props => [
    recipientNumber,
    orderReference,
    dateText,
    timeText,
    totalDataLabel,
    remainingDataLabel,
    dataGiftedLabel,
  ];
}

/// Lowercase label used throughout the gift-data UI ("500 mb", "1 gb", "1.5 gb").
/// Uses the 1 GB = 1000 MB convention so it lines up with the backend's
/// `PlanName` field (e.g. `Amount: 0.5` → "500 mb").
String formatGb(double gb) {
  final mb = (gb * 1000).round();
  return formatMb(mb);
}

/// Convenience wrapper when the value is already in MB.
String formatMb(int mb) {
  if (mb >= 1000 && mb % 1000 == 0) return '${mb ~/ 1000} gb';
  if (mb >= 1000) {
    final gb = mb / 1000;
    final rounded = (gb * 10).round() / 10;
    return '${rounded.toString().replaceFirst(RegExp(r'\.0$'), '')} gb';
  }
  return '$mb mb';
}
