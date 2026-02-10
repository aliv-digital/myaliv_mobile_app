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
      _controller.selection = TextSelection.collapsed(offset: widget.value.length);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(
        color:  Colors.black,
        fontSize: 14,
        fontFamily: 'Circular Pro',
        fontWeight: FontWeight.w500,
        height: 1.43,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF707070),
          fontSize: 14,
          fontFamily: 'Circular Pro',
          fontWeight: FontWeight.w500,
          height: 1.43,
        ),
        filled: true,
        fillColor: AutoRenewAuthPrepaidTheme.textInputFillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
