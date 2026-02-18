import 'package:flutter/material.dart';
import '../../../../login/widgets/focused_input_border_wrapper.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChanged);
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
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RevPrepaidTheme.inputFieldHeight,
      child: FocusedInputBorderWrapper(
        isFocused: _hasFocus,
        unfocusedBorderColor: RevPrepaidTheme.inputFieldBorderColor,
        radius: RevPrepaidTheme.inputFieldRadius,
        borderWidth: RevPrepaidTheme.inputFieldBorderWidth,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: RevPrepaidTheme.fieldBg,
            borderRadius: BorderRadius.circular(RevPrepaidTheme.inputFieldRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
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
        ),
      ),
    );
  }
}
