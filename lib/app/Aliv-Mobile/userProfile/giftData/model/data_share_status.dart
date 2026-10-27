import 'package:equatable/equatable.dart';

/// Response for GET /device/{deviceAccountId}/data-share-status.
///
/// Drives the "until {end date} you can gift up to {send limit}" banner on
/// the gift-data screen. `dataShareEndDate` is parsed as a nullable
/// `DateTime` so a missing/invalid ISO string collapses the banner rather
/// than throwing on screen render.
class DataShareStatus extends Equatable {
  const DataShareStatus({
    required this.dataShareId,
    required this.dataShareEndDate,
    required this.dataQtySent,
    required this.dataQtySendLimit,
    required this.dataAmountSent,
    required this.dataAmountSendLimit,
    required this.dataQtyReceived,
    required this.dataQtyReceivedLimit,
    required this.dataAmountReceived,
    required this.dataAmountReceivedLimit,
    required this.availableToShow,
  });

  final int dataShareId;
  final DateTime? dataShareEndDate;
  final int dataQtySent; // GB
  final int dataQtySendLimit; // GB
  final double dataAmountSent;
  // GB — drives the "you can gift up to" banner cap on the gift-data screen.
  final double dataAmountSendLimit;
  final int dataQtyReceived; // GB
  final int dataQtyReceivedLimit; // GB
  final double dataAmountReceived;
  final double dataAmountReceivedLimit;
  final double availableToShow;

  factory DataShareStatus.fromJson(Map<String, dynamic> json) {
    return DataShareStatus(
      dataShareId: _asInt(json['DataShareID']),
      dataShareEndDate: _asDate(json['DataShareEndDate']),
      dataQtySent: _asInt(json['DataQtySent']),
      dataQtySendLimit: _asInt(json['DataQtySendLimit']),
      dataAmountSent: _asDouble(json['DataAmountSent']),
      dataAmountSendLimit: _asDouble(json['DataAmountSendLimit']),
      dataQtyReceived: _asInt(json['DataQtyReceived']),
      dataQtyReceivedLimit: _asInt(json['DataQtyReceivedLimit']),
      dataAmountReceived: _asDouble(json['DataAmountReceived']),
      dataAmountReceivedLimit: _asDouble(json['DataAmountReceivedLimit']),
      availableToShow: _asDouble(json['AvailableToShow']),
    );
  }

  @override
  List<Object?> get props => [
    dataShareId,
    dataShareEndDate,
    dataQtySent,
    dataQtySendLimit,
    dataAmountSent,
    dataAmountSendLimit,
    dataQtyReceived,
    dataQtyReceivedLimit,
    dataAmountReceived,
    dataAmountReceivedLimit,
    availableToShow,
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

DateTime? _asDate(dynamic v) {
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  if (v is DateTime) return v;
  return null;
}
