import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/make_payment_confirmation_postpaid_theme.dart';

class MpPromoCodeField extends StatefulWidget {
  final String value;
  final bool canApply;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;

  const MpPromoCodeField({
    super.key,
    required this.value,
    required this.canApply,
    required this.onApply,
    required this.onChanged,
  });

  @override
  State<MpPromoCodeField> createState() => _MpPromoCodeFieldState();
}

class _MpPromoCodeFieldState extends State<MpPromoCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant MpPromoCodeField oldWidget) {
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
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: MakePaymentConfirmationPostPaidTheme.promoInput,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'promo code',
                hintStyle: MakePaymentConfirmationPostPaidTheme.promoHint,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.canApply ? widget.onApply : null,
            child: Opacity(
              opacity: widget.canApply ? 1 : 0.55,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Text(
                  'apply',
                  style: MakePaymentConfirmationPostPaidTheme.promoApply,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
