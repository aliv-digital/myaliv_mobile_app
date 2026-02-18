import 'package:flutter/material.dart';
import '../../../../login/widgets/focused_input_border_wrapper.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChanged);
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
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
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
        ),
      ),
    );
  }
}
