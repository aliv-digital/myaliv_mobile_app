import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/app_keyboard_toolbar.dart';
import 'package:flutter/services.dart';

import '../../topup/prepaid/theme/top_up_prepaid_theme.dart';

class TopUpFormInputField extends StatefulWidget {
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String hint;
  final TextEditingController? controller;
  final bool? isAmountType;
  final ValueChanged<String>? onChanged;
  final bool fitHint;

  const TopUpFormInputField({
    super.key,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    required this.hint,
    this.controller,
    this.isAmountType,
    this.onChanged,
    this.fitHint = false,
  });

  @override
  State<TopUpFormInputField> createState() => _TopUpFormInputFieldState();
}

class _TopUpFormInputFieldState extends State<TopUpFormInputField> {
  bool _hasFocus = false;
  final _internalFocusNode = FocusNode();
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final innerRadius =
        (TopUpPrepaidTheme.formInputRadius -
                TopUpPrepaidTheme.formInputBorderWidth)
            .clamp(0.0, TopUpPrepaidTheme.formInputRadius);

    final field = Focus(
      onFocusChange: (hasFocus) {
        if (_hasFocus != hasFocus) {
          setState(() {
            _hasFocus = hasFocus;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: _hasFocus
              ? TopUpPrepaidTheme.focusedInputBorderGradient
              : null,
          border: null,
          borderRadius: BorderRadius.circular(
            TopUpPrepaidTheme.formInputRadius,
          ),
        ),
        padding: const EdgeInsets.all(TopUpPrepaidTheme.formInputBorderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(innerRadius),
          child: Container(
            height: TopUpPrepaidTheme.formInputHeight,
            padding: TopUpPrepaidTheme.formInputHorizontalPadding,
            decoration: BoxDecoration(
              color: TopUpPrepaidTheme.lightBg,
              borderRadius: BorderRadius.circular(
                TopUpPrepaidTheme.formInputRadius,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              focusNode: _focusNode,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              scrollPadding: AppKeyboardToolbar.inputScrollPadding,
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
                hintText: widget.fitHint ? null : widget.hint,
                hint: widget.fitHint
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(widget.hint),
                      )
                    : null,
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
    if (widget.focusNode != null) {
      return field;
    }
    return AppKeyboardToolbar(focusNodes: [_focusNode], child: field);
  }
}
