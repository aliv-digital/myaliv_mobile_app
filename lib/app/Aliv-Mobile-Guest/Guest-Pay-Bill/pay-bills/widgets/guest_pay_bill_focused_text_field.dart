import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_theme.dart';
import 'guest_pay_bill_focused_input_border_wrapper.dart';

class GuestPayBillFocusedTextField extends StatefulWidget {
  const GuestPayBillFocusedTextField({
    super.key,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
    this.prefix,
    this.style,
  });

  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final Widget? prefix;
  final TextStyle? style;

  @override
  State<GuestPayBillFocusedTextField> createState() =>
      _GuestPayBillFocusedTextFieldState();
}

class _GuestPayBillFocusedTextFieldState
    extends State<GuestPayBillFocusedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
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
    return GuestPayBillFocusedInputBorderWrapper(
      isFocused: _hasFocus,
      child: TextField(
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        style: widget.style ?? GuestPayBillTheme.inputTextStyle,
        onChanged: widget.onChanged,
        decoration: GuestPayBillTheme.fieldDecoration(
          hint: widget.hint,
          prefix: widget.prefix,
        ),
      ),
    );
  }
}
