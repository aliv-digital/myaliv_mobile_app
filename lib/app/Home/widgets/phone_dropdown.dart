import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
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
  // Stable notifier — DropdownButton2 subscribes to this once and receives
  // updates whenever the selection changes. Creating a new ValueNotifier on
  // every build() leaves DropdownButton2 subscribed to a stale instance,
  // causing the visible selection to lag behind the actual state.
  // Null initial value intentionally skips DropdownButton2's uniqueness
  // assertion on the first frame (assertion passes when value is null).
  // addPostFrameCallback sets the real value after the first build.
  final ValueNotifier<String?> _selectedNotifier = ValueNotifier<String?>(null);

  // Incremented on every confirmed switch. Each _reloadData call captures
  // its generation at start and exits early whenever it no longer matches,
  // so only the latest switch ever dismisses the overlay.
  int _switchGeneration = 0;
  bool _overlayShowing = false;

  @override
  void dispose() {
    _selectedNotifier.dispose();
    super.dispose();
  }

  String _resolveSelected(
    HomeUiConfig config,
    List<DeviceLimitsModel> devices,
  ) {
    final activeId = config.activeDeviceId;
    if (activeId != null) {
      final matches = devices.where((d) => d.deviceId == activeId);
      if (matches.isNotEmpty) {
        return PhoneDropdownHelper.stripTnSuffix(matches.first.tn);
      }
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
            content: const Text(
              'Are you sure you would like to switch phone numbers?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('no'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onSelected(
    String value,
    List<DeviceLimitsModel> devices,
  ) async {
    final config = context.read<AppUiConfigCubit>().state;
    if (value == _resolveSelected(config, devices)) return;

    // Yield so DropdownButton2 can finish closing its popup route before the dialog opens.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    if (!await _confirmSwitch() || !mounted) return;

    final target = devices.firstWhere(
      (d) => PhoneDropdownHelper.stripTnSuffix(d.tn) == value,
      orElse: () => devices.first,
    );

    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    final primaryPhone = PhoneDropdownHelper.getPrimaryPhone(
      accountInfo,
      devices,
    );
    final isPrimary =
        (value == primaryPhone) ||
        (devices.isNotEmpty && target.deviceId == devices.first.deviceId);

    if (isPrimary) {
      context.read<AppUiConfigCubit>().resetToOwnDevice();
    } else {
      // Role was fetched for the primary device at startup and cached.
      // Child devices have no cached entry — default to fullAccess.
      final roleId = instance<AppUiConfigCubit>().getCachedRole(target.deviceId);
      final LineRole childRole = (roleId == null || roleId == 4)
          ? LineRole.fullAccess
          : LineRole.readOnly;
      if (!mounted) return;
      context.read<AppUiConfigCubit>().switchToDevice(
        target.deviceId,
        lineRole: childRole,
      );
    }
    if (instance.isRegistered<AnalyticsService>()) {
      instance<AnalyticsService>().logAccountLineSwitched();
    }

    final gen = ++_switchGeneration;
    if (!_overlayShowing) {
      _overlayShowing = true;
      _showSwitchingOverlay();
    }
    await _reloadData(target.deviceId, gen);
    if (mounted && gen == _switchGeneration) {
      _overlayShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showSwitchingOverlay() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _reloadData(int deviceId, int gen) async {
    final uiConfig = context.read<AppUiConfigCubit>().state;
    final plansCubit = instance<PlansCubit>();

    // Trigger plans refresh. May set _pendingForceRefresh and return early if
    // a fetch is already in-flight — _waitForPlansSettled handles that case.
    plansCubit.loadInitialPlans(
      userType: uiConfig.userType,
      forceRefresh: true,
    );

    await Future.wait([
      instance<BalanceCubit>().loadBalances(
        deviceAccountId: deviceId,
        forceRefresh: true,
      ),
      _waitForPlansSettled(plansCubit),
    ]);

    if (gen != _switchGeneration) return;

    final plansState = plansCubit.state;
    // Fire-and-forget — bucket-usage and limits do not block the overlay.
    instance<BucketUsageSummaryCubit>().loadBucketUsageSummary(
      deviceAccountId: deviceId,
      activePlans: plansState.activePlansForBucketUsage,
      standAlonePlans: plansState.standAlonePlansForBucketUsage,
      forceRefresh: true,
    );
    if (uiConfig.isPostpaid) {
      instance<ConsumptionLimitCubit>().loadLimits(
        deviceAccountId: deviceId,
        forceRefresh: true,
      );
    }
  }

  // Waits until PlansCubit is no longer in a loading/refreshing state.
  // Loops so it also catches the _pendingForceRefresh second fetch that starts
  // immediately after the in-flight fetch completes: each iteration yields one
  // microtask after settling, then re-checks whether a new fetch has begun.
  // Falls through after 15 s total so the overlay never gets stuck.
  Future<void> _waitForPlansSettled(PlansCubit cubit) async {
    // Yield one microtask so loadInitialPlans can emit its loading state.
    await Future<void>.delayed(Duration.zero);
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (cubit.state.isLoading || cubit.state.isRefreshing) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) break;
      try {
        await cubit.stream
            .firstWhere((s) => !s.isLoading && !s.isRefreshing)
            .timeout(remaining);
      } catch (_) {
        break;
      }
      // Yield one microtask — _pendingForceRefresh may start a new fetch
      // synchronously inside the cubit right after the previous one settles.
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
      bloc: instance<DeviceLimitsCubit>(),
      buildWhen: (prev, curr) => prev.allDeviceLimits != curr.allDeviceLimits,
      builder: (context, deviceState) {
        final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
        final devices = deviceState.allDeviceLimits;
        final visibleNumbers = PhoneDropdownHelper.getVisibleNumbers(
          accountInfo,
          devices,
        );
        final primaryPhone = PhoneDropdownHelper.getPrimaryPhone(
          accountInfo,
          devices,
        );

        return BlocBuilder<AppUiConfigCubit, HomeUiConfig>(
          buildWhen: (prev, curr) => prev.activeDeviceId != curr.activeDeviceId,
          builder: (context, config) {
            final effectiveSelected = () {
              final s = _resolveSelected(config, devices);
              return visibleNumbers.contains(s) ? s : primaryPhone;
            }();
            // Defer notifier update to after the frame — updating a
            // ValueNotifier synchronously inside build() notifies
            // DropdownButton2 mid-frame and corrupts its item-index
            // tracking, causing every other item to become unresponsive.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedNotifier.value != effectiveSelected) {
                _selectedNotifier.value = effectiveSelected;
              }
            });
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
                    valueListenable: _selectedNotifier,
                    isExpanded: true,
                    menuItemStyleData: MenuItemStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      selectedMenuItemBuilder: (ctx, child) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: PhoneDropdownSelectedItem(
                          number: effectiveSelected,
                          isPrimary: effectiveSelected == primaryPhone,
                        ),
                      ),
                    ),
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.zero,
                      height: 48,
                    ),
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
                        .map(
                          (n) => DropdownItem<String>(
                            value: n,
                            height: 48,
                            child: SizedBox(
                              width: double.infinity,
                              child: PhoneDropdownItem(
                                number: n,
                                isPrimary: n == primaryPhone,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) => visibleNumbers
                        .map(
                          (n) => PhoneDropdownItem(
                            number: n,
                            isPrimary: n == primaryPhone,
                            showTrailing: false,
                          ),
                        )
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
