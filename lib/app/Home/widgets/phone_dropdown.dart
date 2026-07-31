import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/home_screen.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown_helper.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown_item.dart';

class PhoneDropdown extends StatefulWidget {
  const PhoneDropdown({super.key});

  @override
  State<PhoneDropdown> createState() => _PhoneDropdownState();
}

class _PhoneDropdownState extends State<PhoneDropdown> {
  late final ValueNotifier<String> selectedNotifier;

  @override
  void initState() {
    super.initState();
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    final devices = instance<DeviceLimitsCubit>().state.allDeviceLimits;
    selectedNotifier = ValueNotifier<String>(
      PhoneDropdownHelper.getPrimaryPhone(accountInfo, devices),
    );
  }

  @override
  void dispose() {
    selectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
      bloc: instance<DeviceLimitsCubit>(),
      buildWhen: (prev, curr) => prev.allDeviceLimits != curr.allDeviceLimits,
      builder: (context, deviceState) {
        return BlocBuilder<AccountInfoCubit, AccountInfoState>(
          builder: (context, accountState) {
            final accountInfo = accountState.accountInfo;
            final devices = deviceState.allDeviceLimits;

            final visibleNumbers = PhoneDropdownHelper.getVisibleNumbers(
              accountInfo,
              devices,
            );
            final primaryPhone = PhoneDropdownHelper.getPrimaryPhone(
              accountInfo,
              devices,
            );

            return ValueListenableBuilder<String>(
              valueListenable: selectedNotifier,
              builder: (context, rawSelected, _) {
                // rawSelected may be stale (e.g. held a value from before devices
                // loaded that is no longer in visibleNumbers). Always resolve to a
                // valid item to satisfy DropdownButton2's uniqueness assertion.
                final effectiveSelected = visibleNumbers.contains(rawSelected)
                    ? rawSelected
                    : primaryPhone;

                // Sync notifier post-frame so future builds start from a valid value.
                if (rawSelected != effectiveSelected) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) selectedNotifier.value = effectiveSelected;
                  });
                }

                final isEnabled = visibleNumbers.length > 1;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white54, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      // Fresh notifier per build — always holds a valid item,
                      // so DropdownButton2's internal uniqueness assert never fires.
                      valueListenable: ValueNotifier<String>(effectiveSelected),
                      isExpanded: true,

                      menuItemStyleData: MenuItemStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        selectedMenuItemBuilder: (ctx, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: PhoneDropdownSelectedItem(
                              number: effectiveSelected,
                              isPrimary: effectiveSelected == primaryPhone,
                            ),
                          );
                        },
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

                      items: visibleNumbers.map((number) {
                        return DropdownItem<String>(
                          value: number,
                          height: 48,
                          child: SizedBox(
                            width: double.infinity,
                            child: PhoneDropdownItem(
                              number: number,
                              isPrimary: number == primaryPhone,
                              showRadio: number == effectiveSelected,
                            ),
                          ),
                        );
                      }).toList(),

                      onChanged: isEnabled
                          ? (value) {
                              if (value != null) selectedNotifier.value = value;
                            }
                          : null,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
