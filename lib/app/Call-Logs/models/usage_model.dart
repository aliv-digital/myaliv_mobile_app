import 'package:equatable/equatable.dart';

/// Model representing a single usage/call log entry from the API
class UsageModel extends Equatable {
  final DateTime date;
  final String usageType;
  final String callType;
  final String numberDialed;
  final String callingParty;
  final String duration;
  final double amount;
  final double tax;
  final String serviceFlow;
  final String rateMeasure;
  final String actualUsage;
  final String ratedUsage;
  final String wallet;
  final String callDesc;
  final String bytes;

  const UsageModel({
    required this.date,
    required this.usageType,
    required this.callType,
    required this.numberDialed,
    required this.callingParty,
    required this.duration,
    required this.amount,
    required this.tax,
    required this.serviceFlow,
    required this.rateMeasure,
    required this.actualUsage,
    required this.ratedUsage,
    required this.wallet,
    required this.callDesc,
    required this.bytes,
  });

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    return UsageModel(
      date: DateTime.parse(json['Date'] as String),
      usageType: json['UsageType'] as String? ?? '',
      callType: json['CallType'] as String? ?? '',
      numberDialed: json['NumberDialed'] as String? ?? '',
      callingParty: json['CallingParty'] as String? ?? '',
      duration: json['Duration'] as String? ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['Tax'] as num?)?.toDouble() ?? 0.0,
      serviceFlow: json['ServiceFlow'] as String? ?? '',
      rateMeasure: json['RateMeasure'] as String? ?? '',
      actualUsage: json['ActualUsage'] as String? ?? '',
      ratedUsage: json['RatedUsage'] as String? ?? '',
      wallet: json['Wallet'] as String? ?? '',
      callDesc: json['CallDesc'] as String? ?? '',
      bytes: json['Bytes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date.toIso8601String(),
      'UsageType': usageType,
      'CallType': callType,
      'NumberDialed': numberDialed,
      'CallingParty': callingParty,
      'Duration': duration,
      'Amount': amount,
      'Tax': tax,
      'ServiceFlow': serviceFlow,
      'RateMeasure': rateMeasure,
      'ActualUsage': actualUsage,
      'RatedUsage': ratedUsage,
      'Wallet': wallet,
      'CallDesc': callDesc,
      'Bytes': bytes,
    };
  }

  /// Check if this is a voice call (incoming or outgoing)
  bool get isVoiceCall => callType.toLowerCase().contains('voice');

  /// Check if this is an incoming call
  bool get isIncoming => serviceFlow.toLowerCase().contains('in');

  /// Check if this is an outgoing call
  bool get isOutgoing => serviceFlow.toLowerCase().contains('out');

  /// Total amount including tax
  double get totalAmount => amount + tax;

  @override
  List<Object?> get props => [
        date,
        usageType,
        callType,
        numberDialed,
        callingParty,
        duration,
        amount,
        tax,
        serviceFlow,
        rateMeasure,
        actualUsage,
        ratedUsage,
        wallet,
        callDesc,
        bytes,
      ];
}
