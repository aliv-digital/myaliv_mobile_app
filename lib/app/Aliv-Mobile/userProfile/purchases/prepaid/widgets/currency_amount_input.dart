import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../topup/prepaid/theme/top_up_prepaid_theme.dart';
import 'keyboard_overlay.dart';

class TopUpFormInputField extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final bool? isAmountType;
  final ValueChanged<String>? onChanged;

  const TopUpFormInputField({
    super.key,
    required this.hint,
    this.controller,
    this.isAmountType,
    this.onChanged,
  });

  @override
  State<TopUpFormInputField> createState() => _TopUpFormInputFieldState();
}

class _TopUpFormInputFieldState extends State<TopUpFormInputField> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final innerRadius = (TopUpPrepaidTheme.formInputRadius -
            TopUpPrepaidTheme.formInputBorderWidth)
        .clamp(0.0, TopUpPrepaidTheme.formInputRadius);

    return Focus(
      onFocusChange: (hasFocus) {
        if (_hasFocus != hasFocus) {
          setState(() {
            _hasFocus = hasFocus;
          });
        }

        if (hasFocus) {
          KeyboardDoneOverlay.show(context);
        } else {
          KeyboardDoneOverlay.hide();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient:
              _hasFocus ? TopUpPrepaidTheme.focusedInputBorderGradient : null,
          border: null,
          borderRadius: BorderRadius.circular(TopUpPrepaidTheme.formInputRadius),
        ),
        padding: const EdgeInsets.all(TopUpPrepaidTheme.formInputBorderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(innerRadius),
          child: Container(
            height: TopUpPrepaidTheme.formInputHeight,
            padding: TopUpPrepaidTheme.formInputHorizontalPadding,
            decoration: BoxDecoration(
              color: TopUpPrepaidTheme.lightBg,
              borderRadius:
                  BorderRadius.circular(TopUpPrepaidTheme.formInputRadius),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              keyboardType: widget.isAmountType == true
                  ? TextInputType.number
                  : TextInputType.name,
              inputFormatters: widget.isAmountType == true
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 14,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 13,
                  color: TopUpPrepaidTheme.textMuted,
                ),
                prefixText: widget.isAmountType == true ? '\$ ' : null,
                prefixStyle: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
