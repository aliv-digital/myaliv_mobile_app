import 'package:equatable/equatable.dart';

/// Model representing a reward from the API
class RewardModel extends Equatable {
  final int rewardId;
  final String name;
  final String shortDesc;
  final String fullDesc;
  final String terms;
  final DateTime? startDate;
  final DateTime? endDate;
  final int categoryId;
  final String logo;
  final int levelId;
  final int sortOrder;
  final String levelName;
  final String categoryName;

  const RewardModel({
    required this.rewardId,
    required this.name,
    required this.shortDesc,
    required this.fullDesc,
    required this.terms,
    this.startDate,
    this.endDate,
    required this.categoryId,
    required this.logo,
    required this.levelId,
    required this.sortOrder,
    required this.levelName,
    required this.categoryName,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      rewardId: json['RewardID'] as int? ?? 0,
      name: json['Name'] as String? ?? '',
      shortDesc: json['ShortDesc'] as String? ?? '',
      fullDesc: json['FullDesc'] as String? ?? '',
      terms: json['Terms'] as String? ?? '',
      startDate: _parseDate(json['StartDate'] as String?),
      endDate: _parseDate(json['EndDate'] as String?),
      categoryId: json['CategoryID'] as int? ?? 0,
      logo: json['Logo'] as String? ?? '',
      levelId: json['LevelID'] as int? ?? 0,
      sortOrder: json['SortOrder'] as int? ?? 0,
      levelName: json['LevelName'] as String? ?? '',
      categoryName: json['CategoryName'] as String? ?? '',
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

  /// Check if reward is currently active
  bool get isActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [
        rewardId, name, shortDesc, fullDesc, terms,
        startDate, endDate, categoryId, logo, levelId,
        sortOrder, levelName, categoryName,
      ];
}
