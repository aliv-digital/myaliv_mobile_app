import 'package:equatable/equatable.dart';
import '../model/reward_details_prepaid_model.dart';

enum RewardDetailsPrepaidStatus { initial, loading, success, failure }

class RewardDetailsPrepaidState extends Equatable {
  final RewardDetailsPrepaidStatus status;
  final RewardDetailsPrepaidModel? details;
  final String? errorMessage;

  const RewardDetailsPrepaidState({
    required this.status,
    required this.details,
    required this.errorMessage,
  });

  factory RewardDetailsPrepaidState.initial() => const RewardDetailsPrepaidState(
    status: RewardDetailsPrepaidStatus.initial,
    details: null,
    errorMessage: null,
  );

  @override
  List<Object?> get props => [status, details, errorMessage];

  RewardDetailsPrepaidState copyWith({
    RewardDetailsPrepaidStatus? status,
    RewardDetailsPrepaidModel? details,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RewardDetailsPrepaidState(
      status: status ?? this.status,
      details: details ?? this.details,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
