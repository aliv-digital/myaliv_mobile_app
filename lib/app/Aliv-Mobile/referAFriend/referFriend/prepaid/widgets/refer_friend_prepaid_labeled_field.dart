import 'package:flutter/material.dart';
import '../theme/refer_friend_prepaid_theme.dart';

class ReferFriendPrepaidLabeledField extends StatefulWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String value;
  final ValueChanged<String> onChanged;

  const ReferFriendPrepaidLabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ReferFriendPrepaidLabeledField> createState() =>
      _ReferFriendPrepaidLabeledFieldState();
}

class _ReferFriendPrepaidLabeledFieldState
    extends State<ReferFriendPrepaidLabeledField> {
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
  void didUpdateWidget(covariant ReferFriendPrepaidLabeledField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(offset: widget.value.length);
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
    final innerRadius = (ReferFriendPrepaidTheme.fieldRadius -
            ReferFriendPrepaidTheme.fieldBorderWidth)
        .clamp(0.0, ReferFriendPrepaidTheme.fieldRadius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: ReferFriendPrepaidTheme.label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            gradient: _hasFocus
                ? ReferFriendPrepaidTheme.focusedInputBorderGradient
                : null,
            border: null,
            borderRadius: BorderRadius.circular(ReferFriendPrepaidTheme.fieldRadius),
          ),
          padding: const EdgeInsets.all(ReferFriendPrepaidTheme.fieldBorderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: Container(
              color: ReferFriendPrepaidTheme.fieldBg,
              padding: const EdgeInsets.symmetric(
                horizontal: ReferFriendPrepaidTheme.fieldHorizontalPadding,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: ReferFriendPrepaidTheme.fieldHint,
                ),
                style: ReferFriendPrepaidTheme.fieldInput,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
