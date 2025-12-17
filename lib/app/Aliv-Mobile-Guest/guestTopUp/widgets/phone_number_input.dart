// lib/features/guest_top_up/guest_top_up/widgets/labeled_input_field.dart
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import '../../../Aliv-Mobile/login/theme/login_theme.dart';

class LabeledInputField extends StatelessWidget {
  const LabeledInputField({super.key,
    required this.label,
    required this.hintText,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: GuestTopUpTheme.inputFieldBackgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: GuestTopUpTheme.inputFieldBackgroundColor,//AuthModuleColors.lightGreyBorder,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: TextField(

            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'CircularPro',
              color: AuthModuleColors.textBlack,
            ),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              fillColor: GuestTopUpTheme.inputFieldBackgroundColor,
              filled: true,
              border: InputBorder.none,
              hintText: 'eg: 242-899-9999',
              hintStyle: TextStyle(
                fontSize: 14,
                color: AuthModuleColors.hintGrey,
              ),
            ),
            onChanged: (value) => onChanged,
          ),
        ),
      ],
    );
  }
}
