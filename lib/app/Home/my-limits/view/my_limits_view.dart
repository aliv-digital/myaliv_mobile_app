import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/limit_row.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_states.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class MyLimitsTab extends StatefulWidget {
  const MyLimitsTab({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color divider = Color(0xFFE0E0E0);

  @override
  State<MyLimitsTab> createState() => _MyLimitsTabState();
}

class _MyLimitsTabState extends State<MyLimitsTab> {
  @override
  void initState() {
    super.initState();
    _loadLimits();
  }

  void _loadLimits() {
    final deviceId = instance<DeviceLimitsCubit>().state.deviceLimits?.deviceId ?? 0;
    if (deviceId > 0) {
      instance<ConsumptionLimitCubit>().loadLimits(deviceAccountId: deviceId);
    }
  }

  Future<void> _refreshLimits() async {
    final deviceId = instance<DeviceLimitsCubit>().state.deviceLimits?.deviceId ?? 0;
    if (deviceId > 0) {
      await instance<ConsumptionLimitCubit>().loadLimits(
        deviceAccountId: deviceId,
        forceRefresh: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: instance<ConsumptionLimitCubit>(),
      child: Container(
        color: Colors.white,
        child: BlocBuilder<ConsumptionLimitCubit, ConsumptionLimitState>(
          builder: (context, state) {
            if (state.isLoading && !state.hasLimits) {
              return const MyLimitsLoadingState();
            }
            if (state.hasError && !state.hasLimits) {
              return MyLimitsErrorState(
                errorMessage: state.errorMessage,
                onRetry: _loadLimits,
              );
            }
            return _buildContent(state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(ConsumptionLimitState state) {
    return RefreshIndicator(
      color: MyLimitsTab.purple,
      onRefresh: _refreshLimits,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          ...state.limits.map(
            (limit) => Column(
              children: [
                LimitRow(limit: limit),
                const Divider(color: MyLimitsTab.divider),
              ],
            ),
          ),
          if (!state.hasLimits && !state.isLoading) const MyLimitsEmptyState(),
          const SizedBox(height: 32),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: () => context.push(AppRoutes.upgradeCreditLimit),
          style: ElevatedButton.styleFrom(
            backgroundColor: MyLimitsTab.purple,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: const Text(
            'update credit limit',
            style: TextStyle(
              color: Color(0xFFF1F1F8),
              fontSize: 15,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
