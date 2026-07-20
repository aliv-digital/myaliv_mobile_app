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
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown_item.dart';

class PhoneDropdown extends StatefulWidget {
  const PhoneDropdown({super.key});

  @override
  State<PhoneDropdown> createState() => _PhoneDropdownState();
}

class _PhoneDropdownState extends State<PhoneDropdown> {
  late final ValueNotifier<String> selectedNotifier;

  // True once the user manually picks a number; prevents auto-updates after that.
  bool _userHasSelected = false;

  @override
  void initState() {
    super.initState();
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    selectedNotifier = ValueNotifier<String>(_getPrimaryPhone(accountInfo));
  }

  @override
  void dispose() {
    selectedNotifier.dispose();
    super.dispose();
  }

  // TNs can arrive as "2428997820_97dc5ea5-fdf7-49d3-83ab-50e735c45791";
  // strip the "_<uuid>" suffix so the same number isn't listed multiple times.
  String _stripTnSuffix(String tn) {
    final i = tn.indexOf('_');
    return i == -1 ? tn : tn.substring(0, i);
  }

  /// Get all phone numbers from TNs or fallback to phoneNumber/altPhoneNumber
  /// Returns a deduplicated list of phone numbers
  List<String> _getPhoneNumbers(dynamic accountInfo) {
    if (accountInfo == null) return [''];

    // Use TNs list if available and not empty
    final tNs = accountInfo.tNs as List<String>?;
    if (tNs != null && tNs.isNotEmpty) {
      // Strip "_<uuid>" suffixes, then deduplicate
      final uniquePhones = <String>{};
      for (final tn in tNs) {
        final phone = _stripTnSuffix(tn.trim());
        if (phone.isNotEmpty) uniquePhones.add(phone);
      }
      return uniquePhones.toList();
    }

    // Fallback: use phoneNumber and/or altPhoneNumber
    final phoneNumber = accountInfo.phoneNumber?.trim() ?? '';
    final altPhoneNumber = accountInfo.altPhoneNumber?.trim() ?? '';

    final phones = <String>{}; // Use Set to avoid duplicates
    if (phoneNumber.isNotEmpty) phones.add(phoneNumber);
    if (altPhoneNumber.isNotEmpty) phones.add(altPhoneNumber);

    return phones.isNotEmpty ? phones.toList() : [''];
  }

  /// Primary phone priority:
  /// 1. TN of the first device from the devices API
  /// 2. primaryPhoneNumber from account info
  /// 3. phoneNumber, then altPhoneNumber
  /// 4. First number in the list
  String _getPrimaryPhone(dynamic accountInfo) {
    if (accountInfo == null) return '';

    final phoneNumbers = _getPhoneNumbers(accountInfo);

    // Priority 1: first device's TN from the devices API
    final devices = instance<DeviceLimitsCubit>().state.allDeviceLimits;
    if (devices.isNotEmpty) {
      final deviceTn = _stripTnSuffix(devices.first.tn.trim());
      if (deviceTn.isNotEmpty && phoneNumbers.contains(deviceTn)) {
        return deviceTn;
      }
    }

    // Priority 2: primaryPhoneNumber from account info
    final primaryPhoneNumber = accountInfo.primaryPhoneNumber?.trim() ?? '';
    if (primaryPhoneNumber.isNotEmpty && phoneNumbers.contains(primaryPhoneNumber)) {
      return primaryPhoneNumber;
    }

    // Priority 3: phoneNumber / altPhoneNumber
    final phoneNumber = accountInfo.phoneNumber?.trim() ?? '';
    if (phoneNumber.isNotEmpty && phoneNumbers.contains(phoneNumber)) {
      return phoneNumber;
    }

    final altPhoneNumber = accountInfo.altPhoneNumber?.trim() ?? '';
    if (altPhoneNumber.isNotEmpty && phoneNumbers.contains(altPhoneNumber)) {
      return altPhoneNumber;
    }

    return phoneNumbers.isNotEmpty ? phoneNumbers.first : '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
      bloc: instance<DeviceLimitsCubit>(),
      buildWhen: (prev, curr) => prev.allDeviceLimits != curr.allDeviceLimits,
      builder: (context, _) {
        return BlocBuilder<AccountInfoCubit, AccountInfoState>(
          builder: (context, state) {
            final accountInfo = state.accountInfo;
            final phoneNumbers = _getPhoneNumbers(accountInfo);
            final primaryPhone = _getPrimaryPhone(accountInfo);

            // Auto-select primary phone until the user makes a manual choice
            if (!_userHasSelected && primaryPhone.isNotEmpty &&
                selectedNotifier.value != primaryPhone) {
              selectedNotifier.value = primaryPhone;
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white54, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  valueListenable: selectedNotifier,
                  isExpanded: true,

                  /// Remove default spacing that allows tick to render
                  menuItemStyleData: MenuItemStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    selectedMenuItemBuilder: (ctx, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: PhoneDropdownSelectedItem(
                          number: selectedNotifier.value,
                          isPrimary: selectedNotifier.value == primaryPhone,
                        ),
                      );
                    },
                  ),

                  /// Button styling
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.zero,
                    height: 48,
                  ),

                  /// Dropdown styling
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
                    icon: SvgPicture.asset('assets/icons/arrow_dropdown.svg'),

                    // openMenuIcon: SvgPicture.asset('assets/icons/selected.svg'),
                  ),

                  style: const TextStyle(
                    color: Color(0xFFF1F1F8),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),

                  items: phoneNumbers.map((number) {
                    return DropdownItem<String>(
                      value: number,
                      height: 48,
                      child: SizedBox(
                        width: double.infinity,
                        child: PhoneDropdownItem(
                          number: number,
                          isPrimary: number == primaryPhone,
                          showRadio: number == selectedNotifier.value,
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value != null) {
                      _userHasSelected = true;
                      selectedNotifier.value = value;
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
