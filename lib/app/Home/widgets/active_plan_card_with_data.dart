import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/home_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/home_plan_state.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/theme/plan_purchase_plan_add_ons_theme.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';

/// Active plan card connected to HomePlanCubit for real-time data.
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
    return BlocBuilder<HomePlanCubit, HomePlanState>(
      buildWhen: (previous, current) {
        // Rebuild when active plan data changes
        return previous.earliestAddOnsPrimaryPlan !=
                current.earliestAddOnsPrimaryPlan ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        final activePlan = state.earliestAddOnsPrimaryPlan;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopRow(autoRenew: activePlan?.autoRenew ?? false),
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
                const _RenewPlanButton(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Top row with "active plan" label and auto-renew toggle
class _TopRow extends StatelessWidget {
  const _TopRow({required this.autoRenew});

  final bool autoRenew;

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
        _AutoRenewToggle(value: autoRenew),
      ],
    );
  }
}

/// Auto-renew toggle (read-only display)
class _AutoRenewToggle extends StatelessWidget {
  const _AutoRenewToggle({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 5.666),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFDCDCDC),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.5),
                child: Text(
                  value ? 'on' : 'off',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
              Container(
                width: 16.67,
                height: 16.67,
                decoration: BoxDecoration(
                  color: value
                      ? const Color(0xFF645D9C)
                      : const Color(0xFFEDECF6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.check : Icons.close,
                  size: 12,
                  color: value ? Colors.white : const Color(0xFF645D9C),
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
            fontVariations: <FontVariation>[
              FontVariation('wght', 450),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dates row showing active and expire dates
class _DatesRow extends StatelessWidget {
  const _DatesRow({
    required this.activeDate,
    required this.expireDate,
  });

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
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
