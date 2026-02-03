import 'package:flutter/material.dart';
import '../theme/rev_prepaid_theme.dart';

class RevAmountField extends StatefulWidget {
  final String value; // formatted "$ 0.00"
  final ValueChanged<String> onChanged;

  const RevAmountField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<RevAmountField> createState() => _RevAmountFieldState();
}

class _RevAmountFieldState extends State<RevAmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RevAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: RevPrepaidTheme.fieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: RevPrepaidTheme.input,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: r'$ 0.00',
          hintStyle: RevPrepaidTheme.hintText,
        ),
      ),
    );
  }
}
