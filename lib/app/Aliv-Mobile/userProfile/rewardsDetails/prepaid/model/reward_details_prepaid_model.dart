import 'package:equatable/equatable.dart';

class RewardDetailsPrepaidModel extends Equatable {
  final String groupName;
  final String promoStartDate;
  final String duration;
  final String limit;
  final String offer;
  final String statusText;

  const RewardDetailsPrepaidModel({
    required this.groupName,
    required this.promoStartDate,
    required this.duration,
    required this.limit,
    required this.offer,
    required this.statusText,
  });

  @override
  List<Object?> get props => [
    groupName,
    promoStartDate,
    duration,
    limit,
    offer,
    statusText,
  ];
}
