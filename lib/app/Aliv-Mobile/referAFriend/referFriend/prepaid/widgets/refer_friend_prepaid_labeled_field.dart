import 'package:flutter/material.dart';
import '../theme/refer_friend_prepaid_theme.dart';

class ReferFriendPrepaidLabeledField extends StatefulWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String value;
  final ValueChanged<String> onChanged;
  final bool showError;
  final bool highlightInputAsError;
  final String? errorText;
  final bool showUnfocusedBorder;

  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const ReferFriendPrepaidLabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.value,
    required this.onChanged,
    this.showError = false,
    this.highlightInputAsError = false,
    this.errorText,
    this.showUnfocusedBorder = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<ReferFriendPrepaidLabeledField> createState() =>
      _ReferFriendPrepaidLabeledFieldState();
}

class _ReferFriendPrepaidLabeledFieldState
    extends State<ReferFriendPrepaidLabeledField> {
  late final TextEditingController _controller;
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _hasFocus = _effectiveFocusNode.hasFocus;
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ReferFriendPrepaidLabeledField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: widget.value.length,
      );
    }
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
    _controller.dispose();
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
    final innerRadius =
        (ReferFriendPrepaidTheme.fieldRadius -
                ReferFriendPrepaidTheme.fieldBorderWidth)
            .clamp(0.0, ReferFriendPrepaidTheme.fieldRadius);
    final bool showNeutralBorder =
        widget.showUnfocusedBorder || widget.showError;
    final Color unfocusedBorderColor = widget.showError
        ? ReferFriendPrepaidTheme.error
        : ReferFriendPrepaidTheme.border;
    final TextStyle inputStyle = widget.highlightInputAsError
        ? ReferFriendPrepaidTheme.fieldInput.copyWith(
            color: ReferFriendPrepaidTheme.error,
          )
        : ReferFriendPrepaidTheme.fieldInput;

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
            border: _hasFocus || !showNeutralBorder
                ? null
                : Border.all(
                    color: unfocusedBorderColor,
                    width: ReferFriendPrepaidTheme.fieldBorderWidth,
                  ),
            borderRadius: BorderRadius.circular(
              ReferFriendPrepaidTheme.fieldRadius,
            ),
          ),
          padding: const EdgeInsets.all(
            ReferFriendPrepaidTheme.fieldBorderWidth,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(innerRadius),
            child: Container(
              color: ReferFriendPrepaidTheme.fieldBg,
              padding: const EdgeInsets.symmetric(
                horizontal: ReferFriendPrepaidTheme.fieldHorizontalPadding,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _effectiveFocusNode,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onSubmitted,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: ReferFriendPrepaidTheme.fieldHint,
                ),
                style: inputStyle,
              ),
            ),
          ),
        ),
        if (widget.showError && (widget.errorText ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(widget.errorText!, style: ReferFriendPrepaidTheme.fieldError),
        ],
      ],
    );
  }
}
