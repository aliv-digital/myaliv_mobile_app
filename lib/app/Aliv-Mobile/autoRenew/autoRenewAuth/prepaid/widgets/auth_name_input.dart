import 'package:flutter/material.dart';
import '../theme/auto_renew_auth_prepaid_theme.dart';

class AuthNameInput extends StatefulWidget {
  final String value;
  final String hintText;
  final ValueChanged<String> onChanged;

  const AuthNameInput({
    super.key,
    required this.value,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<AuthNameInput> createState() => _AuthNameInputState();
}

class _AuthNameInputState extends State<AuthNameInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AuthNameInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: widget.value.length);
    }
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text != widget.value) widget.onChanged(text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusNode,
      builder: (BuildContext context, Widget? child) {
        final bool isFocused = _focusNode.hasFocus;
        final double activeBorderWidth =
            isFocused ? AutoRenewAuthPrepaidTheme.nameInputBorderWidth : 0.0;
        final double innerRadius =
            (AutoRenewAuthPrepaidTheme.nameInputBorderRadius -
                    activeBorderWidth)
                .clamp(0.0, AutoRenewAuthPrepaidTheme.nameInputBorderRadius);

        return Container(
          decoration: BoxDecoration(
            gradient: isFocused
                ? AutoRenewAuthPrepaidTheme.focusedNameInputBorderGradient
                : null,
            borderRadius: AutoRenewAuthPrepaidTheme.nameInputBorderRadiusShape,
          ),
          padding: EdgeInsets.all(activeBorderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AutoRenewAuthPrepaidTheme.nameInputValueTextStyle(),
              decoration: AutoRenewAuthPrepaidTheme.nameInputDecoration(
                hintText: widget.hintText,
              ),
            ),
          ),
        );
      },
    );
  }
}
