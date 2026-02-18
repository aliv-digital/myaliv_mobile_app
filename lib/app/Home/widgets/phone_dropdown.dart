
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../home/home_screen.dart';

class PhoneDropdown extends StatefulWidget {
  const PhoneDropdown({super.key});

  @override
  State<PhoneDropdown> createState() => _PhoneDropdownState();
}

class _PhoneDropdownState extends State<PhoneDropdown> {
  final List<String> phoneNumbers = [
    '242-801-1616',
  ];

  String selected = '242-801-1616';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white54, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          value: selected,
          isExpanded: true,

          /// Remove default spacing that allows tick to render
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            selectedMenuItemBuilder: (ctx, child) {
              return  Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                  child: _buildPhoneItem2(selected)// SvgPicture.asset('assets/icons/selected.svg'),
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
            icon: SvgPicture.asset(
              'assets/icons/arrow_dropdown.svg',
            ),
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
            return DropdownMenuItem<String>(
              value: number,
              child: SizedBox(
                width: double.infinity, // 👈 prevents default tick rendering
                child: _buildPhoneItem(
                  number,
                  showRadio: number == selected,
                ),
              ),
            );
          }).toList(),

          onChanged: (value) {
            if (value != null) {
              setState(() => selected = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPhoneItem(String number, {bool showRadio = false}) {
    final bool isPrimary = number == '242-801-1616';

    return Row(
      children: [
        SvgPicture.asset('assets/icons/Phone.svg'),
        const SizedBox(width: 8),
        Text(number),
        const SizedBox(width: 8),
        if (isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00C4B3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Primary',
              style: TextStyle(
                color: Color(0xFF463C6E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        // const Spacer(),
        // if (showRadio)
      ],
    );
  }
  Widget _buildPhoneItem2(String number) {

    return Row(
      children: [
        SvgPicture.asset('assets/icons/Phone.svg'),
        const SizedBox(width: 8),
        Text(number),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF00C4B3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Primary',
            style: TextStyle(
              color: Color(0xFF463C6E),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        SvgPicture.asset('assets/icons/selected.svg'),

        // if (showRadio)
      ],
    );
  }
}