import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_cards.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plans_expander.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_group.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Home-screen "active plan usage remaining" section. Composes the two
/// section headers with the shared [UsageGroup] (active + roaming cards
/// with sticky labels) and the `ActivePlansExpander`. Postpaid additionally
/// renders the "my limits" header and `MyLimitsCards` below.
class ActivePlanUsageSection extends StatelessWidget {
  const ActivePlanUsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;
    final isPostpaid = config.userType == UserType.postpaid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: 16),
        UsageGroup(isPostpaid: isPostpaid),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ActivePlansExpander(),
        ),
        const SizedBox(height: 20),
        if (isPostpaid) ...[
          _myLimitsHeader(context),
          const SizedBox(height: 10),
          const MyLimitsCards(),
        ],
      ],
    );
  }

  Widget _header(BuildContext context) {
    return _SectionHeader(
      title: 'active plan usage remaining',
      onTap: () => context.go(AppRoutes.usage),
    );
  }

  Widget _myLimitsHeader(BuildContext context) {
    void open() {
      context.read<AppUiConfigCubit>().showMyLimitsView();
      context.go(AppRoutes.usage);
    }

    return _SectionHeader(title: 'my limits', onTap: open);
  }
}

/// Title row with a trailing "view all" affordance. Both elements share the
/// same tap target so users can hit either side of the row.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'view all',
              style: TextStyle(
                color: Color(0xFF645D9C),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF645D9C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
