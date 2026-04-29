import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/auto_renew_actions.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:shimmer/shimmer.dart';

/// Active plan card connected to PlansCubit for real-time data.
///
/// This widget displays the active plan with renew button inside the card,
/// matching the original design from PrepaidActivePlanCard.
class PrepaidActivePlanCardWithData extends StatelessWidget {
  const PrepaidActivePlanCardWithData({super.key});

  String _formatCardDate(DateTime? date) {
    if (date == null) {
      return '--/--/--';
    }
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) {
        return previous.status != current.status ||
            previous.earliestAddOnsPrimaryPlan !=
                current.earliestAddOnsPrimaryPlan ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/icons/Home Active Plan.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: (state.isLoading || state.isInitial)
                ? const _ActivePlanCardSkeleton()
                : _buildContent(state.earliestAddOnsPrimaryPlan),
          ),
        );
      },
    );
  }

  Widget _buildContent(BasePlanModel? activePlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TopRow(),
        Text(
          activePlan?.planName.trim().isNotEmpty == true
              ? activePlan!.planName
              : 'no active plan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _DatesRow(
          activeDate: _formatCardDate(activePlan?.startDateTime),
          expireDate: _formatCardDate(activePlan?.endDateTime),
        ),
        const SizedBox(height: 14),
        // Hide renew button when auto-renew is ON
        BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
          bloc: instance<DeviceLimitsCubit>(),
          buildWhen: (previous, current) =>
              previous.autoRenew != current.autoRenew,
          builder: (context, limitsState) {
            if (limitsState.autoRenew) {
              return const SizedBox.shrink();
            }
            return const _RenewPlanButton();
          },
        ),
      ],
    );
  }
}

/// Skeleton placeholder shown while PlansCubit is loading.
/// Each block mirrors a real element of the card so the layout doesn't shift.
class _ActivePlanCardSkeleton extends StatelessWidget {
  const _ActivePlanCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.25),
      highlightColor: Colors.white.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: "active plan" label + plan name on the left, toggle on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBox(width: 60, height: 12),
                  SizedBox(height: 6),
                  _SkeletonBox(width: 140, height: 24),
                ],
              ),
              const Spacer(),
              Row(
                children: const [
                  _SkeletonBox(width: 44, height: 24, radius: 999),
                  SizedBox(width: 8),
                  _SkeletonBox(width: 62, height: 12),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Dates row: active (left) / expire (right)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBox(width: 36, height: 10),
                  SizedBox(height: 4),
                  _SkeletonBox(width: 70, height: 15),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _SkeletonBox(width: 36, height: 10),
                  SizedBox(height: 4),
                  _SkeletonBox(width: 70, height: 15),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Renew button placeholder
          const _SkeletonBox(
            width: double.infinity,
            height: 50,
            radius: 100,
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Top row with "active plan" label and auto-renew toggle
class _TopRow extends StatelessWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Auto-renew toggle using DeviceLimitsCubit
        BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
          bloc: instance<DeviceLimitsCubit>(),
          buildWhen: (previous, current) =>
              previous.autoRenew != current.autoRenew ||
              previous.isTogglingAutoRenew != current.isTogglingAutoRenew,
          builder: (context, state) {
            return _AutoRenewToggle(
              value: state.autoRenew,
              isLoading: state.isTogglingAutoRenew,
            );
          },
        ),
      ],
    );
  }
}

/// Auto-renew toggle (interactive)
class _AutoRenewToggle extends StatefulWidget {
  const _AutoRenewToggle({
    required this.value,
    this.isLoading = false,
  });

  final bool value;
  final bool isLoading;

  @override
  State<_AutoRenewToggle> createState() => _AutoRenewToggleState();
}

class _AutoRenewToggleState extends State<_AutoRenewToggle> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  @override
  void didUpdateWidget(covariant _AutoRenewToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      isOn = widget.value;
    }
  }

  Future<void> _handleTap() async {
    // Don't allow tap while loading
    if (widget.isLoading) return;

    // Optimistically flip the visual; the cubit will reconcile via didUpdateWidget.
    setState(() => isOn = !isOn);

    await handleAutoRenewToggle(context, currentValue: widget.value);

    // Reconcile against the latest authoritative value once the action settles.
    if (mounted) {
      setState(() => isOn = widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _handleTap,
      child: Opacity(
        opacity: widget.isLoading ? 0.6 : 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 5.666),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFDCDCDC), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.5),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF645D9C),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.5),
                      child: Text(
                        isOn ? 'on' : 'off',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 16.67,
                    height: 16.67,
                    decoration: BoxDecoration(
                      color: isOn
                          ? const Color(0xFF645D9C)
                          : const Color(0xFFEDECF6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOn ? Icons.check : Icons.close,
                      size: 12,
                      color: isOn ? Colors.white : const Color(0xFF645D9C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'auto renew',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w400,
                fontVariations: <FontVariation>[FontVariation('wght', 450)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dates row showing active and expire dates
class _DatesRow extends StatelessWidget {
  const _DatesRow({required this.activeDate, required this.expireDate});

  final String activeDate;
  final String expireDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DateBlock(title: 'active', value: activeDate),
        const Spacer(),
        _DateBlock(title: 'expire', value: expireDate, alignRight: true),
      ],
    );
  }
}

/// Date block (active/expire)
class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.title,
    required this.value,
    this.alignRight = false,
  });

  final String title;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            letterSpacing: 2.25,
          ),
        ),
      ],
    );
  }
}

/// Renew button for active plan card
class _RenewPlanButton extends StatelessWidget {
  const _RenewPlanButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (_) => const AutoRenewBottomSheet(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4FA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/card-add.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFFEF3A4B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'renew your plan',
              style: TextStyle(
                color: Color(0xFFEF3A4B),
                fontSize: 15,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
