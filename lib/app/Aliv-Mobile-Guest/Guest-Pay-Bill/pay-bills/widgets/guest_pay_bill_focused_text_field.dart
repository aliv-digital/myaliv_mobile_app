import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_theme.dart';
import 'guest_pay_bill_focused_input_border_wrapper.dart';

class GuestPayBillFocusedTextField extends StatefulWidget {
  const GuestPayBillFocusedTextField({
    super.key,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.prefix,
    this.style,
    this.isError = false,
    this.focusNode,
  });

  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefix;
  final TextStyle? style;
  final bool isError;
  final FocusNode? focusNode;

  @override
  State<GuestPayBillFocusedTextField> createState() =>
      _GuestPayBillFocusedTextFieldState();
}

class _GuestPayBillFocusedTextFieldState
    extends State<GuestPayBillFocusedTextField> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _hasFocus = _effectiveFocusNode.hasFocus;
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant GuestPayBillFocusedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(
        _onFocusChanged,
      );
      _effectiveFocusNode.addListener(_onFocusChanged);
      _hasFocus = _effectiveFocusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _internalFocusNode)?.removeListener(_onFocusChanged);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_hasFocus != _effectiveFocusNode.hasFocus) {
      setState(() {
        _hasFocus = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GuestPayBillFocusedInputBorderWrapper(
      isFocused: _hasFocus,
      isError: widget.isError,
      child: TextField(
        focusNode: _effectiveFocusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
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
