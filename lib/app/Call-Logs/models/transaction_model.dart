import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Model representing a single transaction entry from the API
class TransactionModel extends Equatable {
  final DateTime date;
  final String? phoneNumber;
  final String type;
  final String plan;
  final double amount;
  final String channel;
  final String? location;
  final String? agent;
  final String? promotion;
  final String? reason;
  final String? reasonDesc;
  final String? initiatingOrderId;
  final int subId;
  final DateTime? planStartDate;

  const TransactionModel({
    required this.date,
    this.phoneNumber,
    required this.type,
    required this.plan,
    required this.amount,
    required this.channel,
    this.location,
    this.agent,
    this.promotion,
    this.reason,
    this.reasonDesc,
    this.initiatingOrderId,
    required this.subId,
    this.planStartDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      date: parseApiDate(json['Date'] as String?) ?? DateTime.now().toUtc(),
      phoneNumber: json['PhoneNumber'] as String?,
      type: json['Type'] as String? ?? '',
      plan: json['Plan'] as String? ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      channel: json['Channel'] as String? ?? '',
      location: json['Location'] as String?,
      agent: json['Agent'] as String?,
      promotion: json['Promotion'] as String?,
      reason: json['Reason'] as String?,
      reasonDesc: json['ReasonDesc'] as String?,
      initiatingOrderId: json['InitiatingOrderID'] as String?,
      subId: json['SubID'] as int? ?? 0,
      planStartDate: parseApiDate(json['PlanStartDate'] as String?),
    );
  }

  /// Check if this is a credit (positive amount)
  bool get isCredit => amount > 0;

  /// Get display title based on type
  String get displayTitle => type.toLowerCase();

  /// Get subtitle - phone number, plan, or channel
  String? get displaySubtitle {
    if (phoneNumber != null && phoneNumber!.isNotEmpty) return phoneNumber;
    if (plan.isNotEmpty) return plan;
    if (channel.isNotEmpty) return channel;
    return null;
  }

  @override
  List<Object?> get props => [
        date, phoneNumber, type, plan, amount, channel,
        location, agent, promotion, reason, reasonDesc,
        initiatingOrderId, subId, planStartDate,
      ];
}
