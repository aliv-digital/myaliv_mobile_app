import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/make_payment_postpaid_theme.dart';

class MpCustomAmountField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const MpCustomAmountField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<MpCustomAmountField> createState() => _MpCustomAmountFieldState();
}

class _MpCustomAmountFieldState extends State<MpCustomAmountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant MpCustomAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      final selection = _controller.selection;
      final maxOffset = widget.value.length;
      final nextSelection = selection.isValid
          ? selection.copyWith(
              baseOffset: math.min(selection.baseOffset, maxOffset),
              extentOffset: math.min(selection.extentOffset, maxOffset),
            )
          : TextSelection.fromPosition(TextPosition(offset: maxOffset));

      _controller.value = _controller.value.copyWith(
        text: widget.value,
        selection: nextSelection,
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = MakePaymentPostPaidTheme.customAmountBorderRadius;
    final borderWidth = MakePaymentPostPaidTheme.customAmountBorderWidth;
    final innerRadius = (radius - borderWidth).clamp(0.0, radius).toDouble();

    return AnimatedBuilder(
      animation: _focusNode,
      builder: (context, _) {
        final isFocused = _focusNode.hasFocus;

        return Container(
          height: 44,
          decoration: BoxDecoration(
            gradient: isFocused
                ? MakePaymentPostPaidTheme.focusedInputBorderGradient
                : null,
            color: isFocused ? null : MakePaymentPostPaidTheme.customAmountBg,
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.all(isFocused ? borderWidth : 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: MakePaymentPostPaidTheme.customAmountBg,
              borderRadius:
                  BorderRadius.circular(isFocused ? innerRadius : radius),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(r'$ ', style: MakePaymentPostPaidTheme.customAmountText),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    keyboardType: TextInputType.number,
                    style: MakePaymentPostPaidTheme.customAmountText,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: '0.00',
                      hintStyle: MakePaymentPostPaidTheme.customAmountHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
