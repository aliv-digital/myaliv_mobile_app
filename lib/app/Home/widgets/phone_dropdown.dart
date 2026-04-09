import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/home_screen.dart';
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
    // Get initial phone number from AccountInfoCubit
    final accountInfoCubit = instance<AccountInfoCubit>();
    final accountInfo = accountInfoCubit.state.accountInfo;
    final primaryPhone = _getPrimaryPhone(accountInfo);
    selectedNotifier = ValueNotifier<String>(primaryPhone);
  }

  @override
  void dispose() {
    selectedNotifier.dispose();
    super.dispose();
  }

  /// Get all phone numbers from TNs or fallback to phoneNumber/altPhoneNumber
  /// Returns a deduplicated list of phone numbers
  List<String> _getPhoneNumbers(dynamic accountInfo) {
    if (accountInfo == null) return [''];

    // Use TNs list if available and not empty
    final tNs = accountInfo.tNs as List<String>?;
    if (tNs != null && tNs.isNotEmpty) {
      // Remove duplicates and empty strings
      final uniquePhones = <String>{};
      for (final tn in tNs) {
        final trimmed = tn.trim();
        if (trimmed.isNotEmpty) {
          uniquePhones.add(trimmed);
        }
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

  /// Get primary phone: uses primaryPhoneNumber, phoneNumber, or altPhoneNumber
  /// Ensures the returned phone is in the list of available phone numbers
  String _getPrimaryPhone(dynamic accountInfo) {
    if (accountInfo == null) return '';

    final phoneNumbers = _getPhoneNumbers(accountInfo);

    final primaryPhoneNumber = accountInfo.primaryPhoneNumber?.trim() ?? '';
    if (primaryPhoneNumber.isNotEmpty &&
        phoneNumbers.contains(primaryPhoneNumber)) {
      return primaryPhoneNumber;
    }

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
    return BlocBuilder<AccountInfoCubit, AccountInfoState>(
      builder: (context, state) {
        final accountInfo = state.accountInfo;
        final phoneNumbers = _getPhoneNumbers(accountInfo);
        final primaryPhone = _getPrimaryPhone(accountInfo);

        // Update selected notifier if primary phone changed
        if (selectedNotifier.value.isEmpty && primaryPhone.isNotEmpty) {
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

                // openMenuIcon:           SvgPicture.asset('assets/icons/selected.svg'),
              ),

              style: const TextStyle(
                color: Color(0xFFF1F1F8),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),

              /// 🔥 IMPORTANT FIX IS HERE
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
                  selectedNotifier.value = value;
                }
              },
            ),
          ),
        );
      },
    );
  }
}
