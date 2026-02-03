import 'package:flutter/material.dart';
import '../theme/rev_prepaid_theme.dart';

class RevTextField extends StatefulWidget {
  final String value;
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  const RevTextField({
    super.key,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
  });

  @override
  State<RevTextField> createState() => _RevTextFieldState();
}

class _RevTextFieldState extends State<RevTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RevTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // keep field in sync with bloc state (prefill/reset)
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
        keyboardType: widget.keyboardType,
        style: RevPrepaidTheme.input,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: RevPrepaidTheme.hintText,
        ),
      ),
    );
  }
}
