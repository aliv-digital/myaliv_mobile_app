import 'dart:async' show unawaited;

import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/home/home_screen.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown_helper.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown_item.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class PhoneDropdown extends StatefulWidget {
  const PhoneDropdown({super.key});

  @override
  State<PhoneDropdown> createState() => _PhoneDropdownState();
}

class _PhoneDropdownState extends State<PhoneDropdown> {
  // Selected TN is derived from AppUiConfigCubit.activeDeviceId — a top-level
  // provider that survives bottom-tab navigation, so no local state is needed.

  String _resolveSelected(HomeUiConfig config, List<DeviceLimitsModel> devices) {
    final activeId = config.activeDeviceId;
    if (activeId != null) {
      final matches = devices.where((d) => d.deviceId == activeId);
      if (matches.isNotEmpty) return PhoneDropdownHelper.stripTnSuffix(matches.first.tn);
    }
    return PhoneDropdownHelper.getPrimaryPhone(
      instance<AccountInfoCubit>().state.accountInfo,
      devices,
    );
  }

  Future<bool> _confirmSwitch() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('switch phone number'),
            content: const Text('Are you sure you would like to switch phone numbers?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('no')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('yes')),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onSelected(String value, List<DeviceLimitsModel> devices) async {
    final config = context.read<AppUiConfigCubit>().state;
    if (value == _resolveSelected(config, devices)) return;
    if (!await _confirmSwitch() || !mounted) return;

    final target = devices.firstWhere(
      (d) => PhoneDropdownHelper.stripTnSuffix(d.tn) == value,
      orElse: () => devices.first,
    );
    context.read<AppUiConfigCubit>().switchToDevice(target.deviceId);
    _reloadData(target.deviceId);
    unawaited(_applyRole(target));
  }

  void _reloadData(int deviceId) {
    final uiConfig = context.read<AppUiConfigCubit>().state;
    instance<BalanceCubit>().loadBalances(deviceAccountId: deviceId, forceRefresh: true);
    instance<PlansCubit>().loadInitialPlans(userType: uiConfig.userType, forceRefresh: true);
    final plansState = instance<PlansCubit>().state;
    instance<BucketUsageSummaryCubit>().loadBucketUsageSummary(
      deviceAccountId: deviceId,
      activePlans: plansState.activePlansForBucketUsage,
      standAlonePlans: plansState.standAlonePlansForBucketUsage,
      forceRefresh: true,
    );
    if (uiConfig.isPostpaid) {
      instance<ConsumptionLimitCubit>().loadLimits(deviceAccountId: deviceId, forceRefresh: true);
    }
  }

  Future<void> _applyRole(DeviceLimitsModel device) async {
    final roleId = await instance<RoleApiClient>().fetchRoleId(device.deviceId);
    if (!mounted) return;
    final LineRole lineRole;
    if (device.parentAccountId == 0) {
      lineRole = LineRole.parent;
    } else if (roleId == 4) {
      lineRole = LineRole.fullAccess;
    } else {
      lineRole = LineRole.readOnly;
    }
    context.read<AppUiConfigCubit>().setLineRole(lineRole);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
      bloc: instance<DeviceLimitsCubit>(),
      buildWhen: (prev, curr) => prev.allDeviceLimits != curr.allDeviceLimits,
      builder: (context, deviceState) {
        final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
        final devices = deviceState.allDeviceLimits;
        final visibleNumbers = PhoneDropdownHelper.getVisibleNumbers(accountInfo, devices);
        final primaryPhone = PhoneDropdownHelper.getPrimaryPhone(accountInfo, devices);

        return BlocBuilder<AppUiConfigCubit, HomeUiConfig>(
          buildWhen: (prev, curr) => prev.activeDeviceId != curr.activeDeviceId,
          builder: (context, config) {
            final effectiveSelected = () {
              final s = _resolveSelected(config, devices);
              return visibleNumbers.contains(s) ? s : primaryPhone;
            }();
            final isEnabled = visibleNumbers.length > 1;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white54, width: 1),
              ),
              child: IgnorePointer(
                ignoring: !isEnabled,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    valueListenable: ValueNotifier<String>(effectiveSelected),
                    isExpanded: true,
                    menuItemStyleData: MenuItemStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      selectedMenuItemBuilder: (ctx, child) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: PhoneDropdownSelectedItem(
                          number: effectiveSelected,
                          isPrimary: effectiveSelected == primaryPhone,
                        ),
                      ),
                    ),
                    buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero, height: 48),
                    dropdownStyleData: DropdownStyleData(
                      offset: const Offset(-16, -4),
                      maxHeight: 250,
                      width: MediaQuery.of(context).size.width - 52,
                      decoration: BoxDecoration(
                        color: HomeScreen.darkPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: isEnabled
                          ? SvgPicture.asset('assets/icons/arrow_dropdown.svg')
                          : const SizedBox.shrink(),
                    ),
                    style: const TextStyle(
                      color: Color(0xFFF1F1F8),
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                    items: visibleNumbers
                        .map((n) => DropdownItem<String>(
                              value: n,
                              height: 48,
                              child: SizedBox(
                                width: double.infinity,
                                child: PhoneDropdownItem(number: n, isPrimary: n == primaryPhone),
                              ),
                            ))
                        .toList(),
                    selectedItemBuilder: (context) => visibleNumbers
                        .map((n) => PhoneDropdownItem(
                              number: n,
                              isPrimary: n == primaryPhone,
                              showTrailing: false,
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) _onSelected(value, devices);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
