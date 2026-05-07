import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_skeleton.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../../../core/appConfig/app_ui_config_cubit.dart';
import '../../../router/app_routes.dart';

/// Active plan card for postpaid users connected to PlansCubit for real-time data.
///
/// Displays plan name, active/expire dates from PrimaryPlans[0] (earliest plan).
class PostpaidActivePlanCard extends StatelessWidget {
  final HomeUiConfig config;
  const PostpaidActivePlanCard({super.key, required this.config});

  static const Color red = Color(0xFFD94B4B);
  static const Color lightBg = Color(0xFFF4F5FA);

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
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/icons/Home Active Plan.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: (state.isLoading || state.isInitial)
                ? const ActivePlanCardSkeleton()
                : _buildContent(context, state.earliestAddOnsPrimaryPlan),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, BasePlanModel? activePlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with title and auto-renew toggle
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

        const SizedBox(height: 12),

        // Dates
        Row(
          children: [
            _DateBlock(
              label: 'active',
              value: _formatCardDate(activePlan?.startDateTime),
              alignRight: false,
            ),
            const Spacer(),
            _DateBlock(
              label: 'expire',
              value: _formatCardDate(activePlan?.endDateTime),
              alignRight: true,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ================= CTA =================
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<AppUiConfigCubit>().showMyLimitsView();
              context.go(AppRoutes.usage);
            },
            icon: SvgPicture.asset(
              'assets/icons/card-add.svg',
              colorFilter: const ColorFilter.mode(
                Color(0xFFEF3A4B),
                BlendMode.srcIn,
              ),
            ),
            label: const Text(
              'upgrade credit limit',
              style: TextStyle(
                color: Color(0xFFEF3A4B),
                fontSize: 15,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: lightBg,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;

  const _DateBlock({
    required this.label,
    required this.value,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
            fontSize: 10,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
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
        // Auto-pay invoice toggle using AccountInfoCubit (postpaid)
        // hidden auto pay
        // BlocBuilder<AccountInfoCubit, AccountInfoState>(
        //   bloc: instance<AccountInfoCubit>(),
        //   buildWhen: (previous, current) =>
        //       previous.autoPayInvoice != current.autoPayInvoice ||
        //       previous.isTogglingAutoPayInvoice !=
        //           current.isTogglingAutoPayInvoice,
        //   builder: (context, state) {
        //     return _AutoPayToggle(
        //       value: state.autoPayInvoice,
        //       isLoading: state.isTogglingAutoPayInvoice,
        //     );
        //   },
        // ),
      ],
    );
  }
}

/// Auto-pay invoice toggle (interactive) for postpaid
class _AutoPayToggle extends StatefulWidget {
  const _AutoPayToggle({
    required this.value,
    this.isLoading = false,
  });

  final bool value;
  final bool isLoading;

  @override
  State<_AutoPayToggle> createState() => _AutoPayToggleState();
}

class _AutoPayToggleState extends State<_AutoPayToggle> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  @override
  void didUpdateWidget(covariant _AutoPayToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      isOn = widget.value;
    }
  }

  Future<void> _handleTap() async {
    // Don't allow tap while loading
    if (widget.isLoading) return;

    final newValue = !isOn;

    if (newValue) {
      // Toggle OFF → ON: Show bottom sheet to go to auth screen
      setState(() => isOn = true);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => const AutoPayBottomSheet(),
      ).then((_) {
        // Revert if bottom sheet dismissed without enabling
        if (mounted) {
          setState(() => isOn = widget.value);
        }
      });
    } else {
      // Toggle ON → OFF: confirm via bottom sheet before hitting the API.
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => const DisableAutoPayBottomSheet(),
      );
      if (!mounted) return;
      if (confirmed != true) {
        setState(() => isOn = widget.value);
        return;
      }

      setState(() => isOn = false);

      final success =
          await instance<AccountInfoCubit>().disableAutoPayInvoice();

      if (!success && mounted) {
        // Revert on failure
        setState(() => isOn = true);
        AppToast.show(
          message: 'Failed to disable auto-pay',
          type: ToastType.error,
        );
      } else if (success) {
        AppToast.show(
          message:
              "We're working on it! Auto-pay takes a few minutes to update. Thank you for your patience.",
          type: ToastType.success,
        );
      }
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
              'auto pay',
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
