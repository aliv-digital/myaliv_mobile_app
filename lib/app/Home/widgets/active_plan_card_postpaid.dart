import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';

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
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
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
                // Title
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
                const SizedBox(height: 1),

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
            ),
          ),
        );
      },
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
