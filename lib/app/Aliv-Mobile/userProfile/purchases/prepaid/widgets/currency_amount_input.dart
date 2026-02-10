import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../topup/prepaid/theme/top_up_prepaid_theme.dart';
import 'keyboard_overlay.dart';

class TopUpFormInputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool? isAmountType;

  const TopUpFormInputField({
    super.key,
    required this.hint,
    this.controller,
    this.isAmountType,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          KeyboardDoneOverlay.show(context);
        } else {
          KeyboardDoneOverlay.hide();
        }
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: TopUpPrepaidTheme.lightBg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: controller,
          keyboardType: isAmountType == true
              ? TextInputType.number
              : TextInputType.name,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,contentPadding: EdgeInsets.zero,
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 13,
              color: TopUpPrepaidTheme.textMuted,
            ),
            prefixText: '\$ ',
            prefixStyle: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
