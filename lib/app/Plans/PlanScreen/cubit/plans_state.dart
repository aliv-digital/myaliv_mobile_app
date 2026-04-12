import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
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
  final List<DailyPlanModel> dailyPlans;
  final List<WeeklyPlanModel> weeklyPlans;
  final List<MonthlyPlanModel> monthlyPlans;
  final List<RoamingPlanModel> roamingPlans;
  final List<RoamEasyPlanModel> roamEasyPlans;
  final List<MifiPlanModel> mifiPlans;
  final List<LibertyGlobalPlanModel> libertyGlobalPlans;
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
    List<DailyPlanModel>? dailyPlans,
    List<WeeklyPlanModel>? weeklyPlans,
    List<MonthlyPlanModel>? monthlyPlans,
    List<RoamingPlanModel>? roamingPlans,
    List<RoamEasyPlanModel>? roamEasyPlans,
    List<MifiPlanModel>? mifiPlans,
    List<LibertyGlobalPlanModel>? libertyGlobalPlans,
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
