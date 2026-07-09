import 'package:equatable/equatable.dart';

/// Response for GET /Account/top-up-limit-left.
///
/// Backend sends [earliestTopUpDate] as bare `"YYYY-MM-DD HH:mm:ss"` in UTC
/// (no `Z`, no `T`). We normalize to ISO-8601 + `Z` at parse time and store
/// the result already converted to device-local time, so UI code never has
/// to think about timezones.
class TopUpLimitLeft extends Equatable {
  final double limitLeft;
  final DateTime? earliestTopUpDateLocal;

  const TopUpLimitLeft({
    required this.limitLeft,
    this.earliestTopUpDateLocal,
  });

  factory TopUpLimitLeft.fromJson(Map<String, dynamic> json) {
    return TopUpLimitLeft(
      limitLeft: (json['TopUp24HourLimitLeft'] as num?)?.toDouble() ?? 0.0,
      earliestTopUpDateLocal: _parseUtcLocal(json['EarliestTopUpDate']),
    );
  }

  static DateTime? _parseUtcLocal(dynamic raw) {
    if (raw is! String || raw.isEmpty) return null;
    final iso = '${raw.replaceFirst(' ', 'T')}Z';
    return DateTime.tryParse(iso)?.toLocal();
  }

  @override
  List<Object?> get props => [limitLeft, earliestTopUpDateLocal];
}
