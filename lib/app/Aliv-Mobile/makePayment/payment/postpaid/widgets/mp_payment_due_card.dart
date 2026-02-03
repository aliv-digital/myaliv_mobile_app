import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bloc/make_payment_postpaid_event.dart';
import '../theme/make_payment_postpaid_theme.dart';

class MpPaymentDueCard extends StatelessWidget {
  final String amountText;
  final MpAmountOption selectedOption;
  final String customAmount;
  final ValueChanged<MpAmountOption> onOptionChanged;
  final ValueChanged<String> onCustomAmountChanged;

  const MpPaymentDueCard({
    super.key,
    required this.amountText,
    required this.selectedOption,
    required this.customAmount,
    required this.onOptionChanged,
    required this.onCustomAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('payment due', style: MakePaymentPostPaidTheme.sectionLabel),
          const SizedBox(height: 8),
          _AmountField(value: amountText),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AmountOptionTile(
                  label: 'pay current\namount',
                  isSelected: selectedOption == MpAmountOption.current,
                  onTap: () => onOptionChanged(MpAmountOption.current),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AmountOptionTile(
                  label: 'other\namount',
                  isSelected: selectedOption == MpAmountOption.other,
                  onTap: () => onOptionChanged(MpAmountOption.other),
                ),
              ),
            ],
          ),
          if (selectedOption == MpAmountOption.other) ...[
            const SizedBox(height: 12),
            Text('enter a custom amount',
                style: MakePaymentPostPaidTheme.helperLabel),
            const SizedBox(height: 8),
            _CustomAmountField(
              value: customAmount,
              onChanged: onCustomAmountChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final String value;

  const _AmountField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.amountFieldBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(value, style: MakePaymentPostPaidTheme.amountText),
    );
  }
}

class _AmountOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? MakePaymentPostPaidTheme.optionSelectedBorder
        : MakePaymentPostPaidTheme.border;
    final bgColor = isSelected
        ? MakePaymentPostPaidTheme.optionSelectedBg
        : Colors.white;
    final textStyle = isSelected
        ? MakePaymentPostPaidTheme.optionTextSelected
        : MakePaymentPostPaidTheme.optionText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 56,
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label, style: textStyle),
            ),
            _SelectionIndicator(selected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;

  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? MakePaymentPostPaidTheme.primary
        : MakePaymentPostPaidTheme.radioBorder;

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
        color: selected ? MakePaymentPostPaidTheme.primary : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}

class _CustomAmountField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CustomAmountField({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_CustomAmountField> createState() => _CustomAmountFieldState();
}

class _CustomAmountFieldState extends State<_CustomAmountField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _CustomAmountField oldWidget) {
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.customAmountBg,
        borderRadius: BorderRadius.circular(8),
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
    );
  }
}
