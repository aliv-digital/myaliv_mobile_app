import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/models/consumption_limit_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_shimmer.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_card.dart';

/// Displays consumption limits as horizontal scrollable cards
/// Used in home screen "my limits" section for postpaid users
class MyLimitsCards extends StatelessWidget {
  const MyLimitsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: instance<ConsumptionLimitCubit>(),
      child: BlocBuilder<ConsumptionLimitCubit, ConsumptionLimitState>(
        builder: (context, state) {
          if (state.isLoading && !state.hasLimits) {
            return _buildLoading();
          }

          if (!state.hasLimits) {
            return _buildEmpty();
          }

          return _buildCards(state.limits);
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const MyLimitsShimmer();
  }

  Widget _buildEmpty() {
    return const SizedBox(
      height: 160,
      child: Center(
        child: Text(
          'No limits available',
          style: TextStyle(
            color: Color(0xFF707070),
            fontSize: 14,
            fontFamily: 'CircularPro',
          ),
        ),
      ),
    );
  }

  Widget _buildCards(List<ConsumptionLimitModel> limits) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: limits.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final limit = limits[index];
          // need to fix here
          // Title should show - local talk mins, int'I roaming.
          // should use condition and hard code here
          return UsageCard(
            icon: _getIconForLimit(limit.name),
            title: limit.displayName,
            totalValue: '\$${limit.remainingAmount.toStringAsFixed(2)}',
            totalRemaining: '\$${limit.initialAmount.toStringAsFixed(2)}',
            remainingLabel: 'remaining',
            progress: _calculateProgress(limit),
            color: _getColorForLimit(limit.name),
            isPostpaid: true,
          );
        },
      ),
    );
  }

  String _getIconForLimit(String name) {
    switch (name) {
      case 'C_SMS_local_Restriction':
        return 'assets/icons/message.svg';
      case 'C_GPRS_Local':
        return 'assets/icons/Rss.svg';
      case 'C_Voice_local_restriction':
        return 'assets/icons/phone_call.svg';
      case 'C_IR_restriction':
        return 'assets/icons/Rss.svg';
      case 'C_IDD_Restriction':
        return 'assets/icons/phone_call.svg';
      default:
        return 'assets/icons/Rss.svg';
    }
  }

  Color _getColorForLimit(String name) {
    switch (name) {
      case 'C_SMS_local_Restriction':
        return const Color(0xFF5045A7);
      case 'C_GPRS_Local':
        return const Color(0xFFFF6C36);
      case 'C_Voice_local_restriction':
        return const Color(0xFF00B3E3);
      case 'C_IR_restriction':
        return const Color(0xFF8B5CF6);
      case 'C_IDD_Restriction':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF5045A7);
    }
  }

  /// Progress = fraction USED (used/initial). The bar fills as consumption
  /// approaches the limit so threshold-based coloring (green → yellow → red)
  /// reads correctly.
  double _calculateProgress(ConsumptionLimitModel limit) {
    if (limit.initialAmount <= 0) return 0;
    return (limit.usedAmount / limit.initialAmount).clamp(0.0, 1.0);
  }
}
