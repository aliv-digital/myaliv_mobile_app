import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Status of plan fetching
enum PlansStatus {
  /// Initial state
  initial,

  /// Loading plans
  loading,

  /// Plans loaded successfully
  success,

  /// Failed to load plans
  failure,
}

/// State for Plans Cubit
class PlansState extends Equatable {
  const PlansState({
    this.status = PlansStatus.initial,
    this.dailyPlans = const [],
    this.weeklyPlans = const [],
    this.monthlyPlans = const [],
    this.roamingPlans = const [],
    this.roamEasyPlans = const [],
    this.mifiPlans = const [],
    this.libertyGlobalPlans = const [],
    this.postpaidRoamingPlans = const [],
    this.errorMessage,
    this.lastFetchedAt,
  });

  final PlansStatus status;
  final List<BasePlanModel> dailyPlans;
  final List<BasePlanModel> weeklyPlans;
  final List<BasePlanModel> monthlyPlans;
  final List<BasePlanModel> roamingPlans;
  final List<BasePlanModel> roamEasyPlans;
  final List<BasePlanModel> mifiPlans;
  final List<BasePlanModel> libertyGlobalPlans;
  final List<HomePlansPostPaidPlanModel> postpaidRoamingPlans;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  /// Convenience getters
  bool get isLoading => status == PlansStatus.loading;
  bool get isSuccess => status == PlansStatus.success;
  bool get isFailure => status == PlansStatus.failure;
  bool get isInitial => status == PlansStatus.initial;

  bool get hasData =>
      dailyPlans.isNotEmpty ||
      weeklyPlans.isNotEmpty ||
      monthlyPlans.isNotEmpty ||
      roamingPlans.isNotEmpty;

  PlansState copyWith({
    PlansStatus? status,
    List<BasePlanModel>? dailyPlans,
    List<BasePlanModel>? weeklyPlans,
    List<BasePlanModel>? monthlyPlans,
    List<BasePlanModel>? roamingPlans,
    List<BasePlanModel>? roamEasyPlans,
    List<BasePlanModel>? mifiPlans,
    List<BasePlanModel>? libertyGlobalPlans,
    List<HomePlansPostPaidPlanModel>? postpaidRoamingPlans,
    String? errorMessage,
    DateTime? lastFetchedAt,
  }) {
    return PlansState(
      status: status ?? this.status,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      weeklyPlans: weeklyPlans ?? this.weeklyPlans,
      monthlyPlans: monthlyPlans ?? this.monthlyPlans,
      roamingPlans: roamingPlans ?? this.roamingPlans,
      roamEasyPlans: roamEasyPlans ?? this.roamEasyPlans,
      mifiPlans: mifiPlans ?? this.mifiPlans,
      libertyGlobalPlans: libertyGlobalPlans ?? this.libertyGlobalPlans,
      postpaidRoamingPlans: postpaidRoamingPlans ?? this.postpaidRoamingPlans,
      errorMessage: errorMessage,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dailyPlans,
        weeklyPlans,
        monthlyPlans,
        roamingPlans,
        roamEasyPlans,
        mifiPlans,
        libertyGlobalPlans,
        postpaidRoamingPlans,
        errorMessage,
        lastFetchedAt,
      ];
}
