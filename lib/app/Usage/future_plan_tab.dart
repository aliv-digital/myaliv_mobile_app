import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Usage/repository/usage_repository.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/future_plan_card.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class FuturePlansTab extends StatelessWidget {
  const FuturePlansTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: const [_StandAloneFuturePlans()],
      ),
    );
  }
}

/// Future plans = PrimaryPlans + StandAlonePlans whose StartDate is strictly
/// after today (date-only comparison, ignoring time-of-day).
/// Used for both prepaid and postpaid users.
class _StandAloneFuturePlans extends StatelessWidget {
  const _StandAloneFuturePlans();

  static const List<String> _planImages = [
    'assets/images/Future Plan 1.png',
    'assets/images/Future Plan 2.png',
    'assets/images/Future Plan 3.png',
  ];

  String _formatCardDate(DateTime? date) {
    if (date == null) {
      return '--/--/--';
    }
    return DateFormat('dd/MM/yy').format(date);
  }

  bool _startsInFuture(BasePlanModel plan) {
    final start = plan.startDateTime;
    if (start == null) return false;
    return start.isAfter(DateTime.now());
  }

  int? _earliestFuturePrimaryPlanIndex(List<BasePlanModel> plans) {
    int? earliestIndex;
    DateTime? earliestStartDate;

    for (var i = 0; i < plans.length; i++) {
      final plan = plans[i];
      final startDate = plan.startDateTime;
      if (!plan.isPrimaryPlan || startDate == null) continue;

      if (earliestStartDate == null || startDate.isBefore(earliestStartDate)) {
        earliestIndex = i;
        earliestStartDate = startDate;
      }
    }

    return earliestIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isPostpaid = context.watch<AppUiConfigCubit>().state.isPostpaid;

    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) {
        return previous.standAlonePlans != current.standAlonePlans ||
            previous.addOnsApiPrimaryPlans != current.addOnsApiPrimaryPlans ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        final futurePlans = <BasePlanModel>[
          ...state.addOnsApiPrimaryPlans.where(_startsInFuture),
          ...state.standAlonePlans.where(_startsInFuture),
        ];
        final startablePlanIndex =
            isPostpaid ? null : _earliestFuturePrimaryPlanIndex(futurePlans);

        if (futurePlans.isEmpty) {
          return const _EmptyFuturePlansMessage();
        }

        return Column(
          children: [
            for (var i = 0; i < futurePlans.length; i++) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FuturePlanCard(
                  title: futurePlans[i].planName,
                  startDate: _formatCardDate(futurePlans[i].startDateTime),
                  endDate: _formatCardDate(futurePlans[i].endDateTime),
                  image: _planImages[i % _planImages.length],
                  isActivePlan: false,
                ),
              ),
              if (i == startablePlanIndex) ...[
                const _StartPlanButton(),
                const SizedBox(height: 16),
              ],
            ],
          ],
        );
      },
    );
  }
}

/// Empty state when no future plans are available
class _EmptyFuturePlansMessage extends StatelessWidget {
  const _EmptyFuturePlansMessage();

  @override
  Widget build(BuildContext context) {
    // Calculate available height for centering
    final screenHeight = MediaQuery.of(context).size.height / 2;
    // Approximate height: screen - appBar(~140) - tabBar(~82) - padding(~60)
    final availableHeight = screenHeight - 282;

    return SizedBox(
      height: availableHeight > 200 ? availableHeight : 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: Color(0xFF9E9E9E),
            ),
            SizedBox(height: 16),
            Text(
              'no future plans scheduled',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 16,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static first plan for prepaid users (existing behavior)
class _PrepaidStaticFuturePlan extends StatelessWidget {
  const _PrepaidStaticFuturePlan();

  @override
  Widget build(BuildContext context) {
    return const FuturePlanCard(
      title: 'liberty45',
      startDate: '06/01/25',
      endDate: '05/02/25',
      image: 'assets/images/Future Plan 1.png',
      isActivePlan: true,
    );
  }
}

class _StartPlanButton extends StatefulWidget {
  const _StartPlanButton();

  static const Color purple = Color(0xFF645D9C);

  @override
  State<_StartPlanButton> createState() => _StartPlanButtonState();
}

class _StartPlanButtonState extends State<_StartPlanButton> {
  final UsageRepository _usageRepository = UsageRepository();

  bool _isStartingPlan = false;

  Future<void> _startFuturePlan() async {
    if (_isStartingPlan) return;

    setState(() {
      _isStartingPlan = true;
    });

    try {
      final account = context.read<AccountInfoCubit>().state.accountInfo;
      if (account == null || account.idAcc <= 0) {
        AppToast.show(
          message: 'Account information not available',
          type: ToastType.error,
        );
        return;
      }

      final success = await _usageRepository.jumpStartFuturePlan(
        deviceAccountId: account.idAcc,
      );

      if (!mounted) return;

      if (success) {
        AppToast.show(
          message: 'success! your future plan has started',
          type: ToastType.success,
        );
        await _refreshPlansAfterSuccess();
      } else {
        AppToast.show(
          message: 'Failed to start future plan. Please try again.',
          type: ToastType.error,
        );
      }
    } on UsageRepositoryException catch (error) {
      if (!mounted) return;
      AppToast.show(message: error.message, type: ToastType.error);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        message: 'Failed to start future plan. Please try again.',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isStartingPlan = false;
        });
      }
    }
  }

  Future<void> _refreshPlansAfterSuccess() async {
    try {
      await context.read<PlansCubit>().refreshCurrentTab();
    } catch (error) {
      debugPrint('Future plans refresh failed after jump start: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: _isStartingPlan ? null : _startFuturePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _StartPlanButton.purple,
          disabledBackgroundColor: _StartPlanButton.purple,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: _isStartingPlan
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF1F1F8)),
                ),
              )
            : const Text(
                'start plan',
                style: TextStyle(
                  color: Color(0xFFF1F1F8),
                  fontSize: 15,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
