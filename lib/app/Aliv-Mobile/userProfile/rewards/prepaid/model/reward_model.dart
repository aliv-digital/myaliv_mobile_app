import 'package:equatable/equatable.dart';

class RewardModel extends Equatable {
  final int sugId;
  final String name;
  final String description;
  final String typeName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int duration;
  final int limit;
  final String? offer;
  final double creditPercent;
  final String creditRecipient;
  final String billType;
  final bool selfSubscribe;
  final bool planExclusive;

  const RewardModel({
    required this.sugId,
    required this.name,
    required this.description,
    required this.typeName,
    required this.status,
    this.startDate,
    this.endDate,
    required this.duration,
    required this.limit,
    this.offer,
    required this.creditPercent,
    required this.creditRecipient,
    required this.billType,
    required this.selfSubscribe,
    required this.planExclusive,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      sugId: json['SUGID'] as int? ?? 0,
      name: json['SUGName'] as String? ?? '',
      description: json['SUGDesc'] as String? ?? '',
      typeName: json['SUGTypeName'] as String? ?? '',
      status: json['Status'] as String? ?? '',
      startDate: _parseDate(json['StartDate'] as String?),
      endDate: _parseDate(json['EndDate'] as String?),
      duration: json['Duration'] as int? ?? 0,
      limit: json['Limit'] as int? ?? 0,
      offer: json['Offer'] as String?,
      creditPercent: (json['CreditPercent'] as num?)?.toDouble() ?? 0.0,
      creditRecipient: json['CreditRecipient'] as String? ?? '',
      billType: json['SUGBillType'] as String? ?? '',
      selfSubscribe: json['SelfSubscribe'] as bool? ?? false,
      planExclusive: json['PlanExclusive'] as bool? ?? false,
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    sugId,
    name,
    description,
    typeName,
    status,
    startDate,
    endDate,
    duration,
    limit,
    offer,
    creditPercent,
    creditRecipient,
    billType,
    selfSubscribe,
    planExclusive,
  ];
}
