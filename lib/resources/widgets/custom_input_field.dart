import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable input with gradient border on focus.
/// Supports dynamic keyboard/input behavior (text, number, multiline, etc.).
class CustomInputField extends StatefulWidget {
  const CustomInputField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onSubmitted,
    this.onTap,
    this.style,
    this.hintStyle,
    this.cursorColor,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
    this.height = 48,
    this.backgroundColor = const Color(0xFFF3F2FB),
    this.unfocusedBorderColor = const Color(0xFFE0E0E0),
    this.radius = 8,
    this.borderWidth = 1,
    this.focusedBorderGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: <Color>[
        Color(0xFFFFC627),
        Color(0xFF00B3E3),
        Color(0xFF4B298C),
        Color(0xFFFF9BB1),
        Color(0xFFFF6C36),
      ],
    ),
    this.prefix,
    this.suffix,
  });

  final String value;
  final ValueChanged<String> onChanged;

  final String? hintText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  final int maxLines;
  final int? minLines;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  final TextStyle? style;
  final TextStyle? hintStyle;
  final Color? cursorColor;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final EdgeInsets contentPadding;

  final double? height;
  final Color backgroundColor;
  final Color unfocusedBorderColor;
  final double radius;
  final double borderWidth;
  final LinearGradient focusedBorderGradient;

  final Widget? prefix;
  final Widget? suffix;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
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
  void didUpdateWidget(covariant CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep controller text synced with external state updates.
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
    final field = Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        style: widget.style,
        cursorColor: widget.cursorColor,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        decoration: InputDecoration(
          isDense: false,
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
          contentPadding: widget.contentPadding,
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffix,
        ),
      ),
    );

    final wrappedField = Container(
      decoration: BoxDecoration(
        gradient: _hasFocus ? widget.focusedBorderGradient : null,
        border: _hasFocus
            ? null
            : Border.all(
                color: widget.unfocusedBorderColor,
                width: widget.borderWidth,
              ),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      padding: EdgeInsets.all(widget.borderWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          (widget.radius - widget.borderWidth).clamp(0.0, widget.radius),
        ),
        child: field,
      ),
    );

    if (widget.height == null) return wrappedField;
    return SizedBox(height: widget.height, child: wrappedField);
  }
}
