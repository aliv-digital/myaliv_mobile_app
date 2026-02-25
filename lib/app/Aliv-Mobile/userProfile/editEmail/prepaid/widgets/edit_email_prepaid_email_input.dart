import 'package:flutter/material.dart';
import '../theme/edit_email_prepaid_theme.dart';

class EditEmailPrepaidEmailInput extends StatefulWidget {
  final String initialValue;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const EditEmailPrepaidEmailInput({
    super.key,
    required this.initialValue,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<EditEmailPrepaidEmailInput> createState() => _EditEmailPrepaidEmailInputState();
}

class _EditEmailPrepaidEmailInputState extends State<EditEmailPrepaidEmailInput> {
  late final TextEditingController _c;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant EditEmailPrepaidEmailInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _c.text != widget.initialValue) {
      _c.text = widget.initialValue;
      _c.selection = TextSelection.collapsed(offset: _c.text.length);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _c.dispose();
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
    final innerRadius = (EditEmailPrepaidTheme.editEmailInputRadius -
            EditEmailPrepaidTheme.inputBorderWidth)
        .clamp(0.0, EditEmailPrepaidTheme.editEmailInputRadius);

    return Container(
      decoration: BoxDecoration(
        gradient: _hasFocus ? EditEmailPrepaidTheme.focusedInputBorderGradient : null,
        border: _hasFocus
            ? null
            : Border.all(
                color: EditEmailPrepaidTheme.inputBorder,
                width: EditEmailPrepaidTheme.inputBorderWidth,
              ),
        borderRadius: BorderRadius.circular(EditEmailPrepaidTheme.editEmailInputRadius),
      ),
      padding: const EdgeInsets.all(EditEmailPrepaidTheme.inputBorderWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: EditEmailPrepaidTheme.inputBg,
            borderRadius: BorderRadius.circular(EditEmailPrepaidTheme.editEmailInputRadius),
          ),
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
          alignment: Alignment.center,
          child: TextField(
            focusNode: _focusNode,
            controller: _c,
            enabled: widget.enabled,
            keyboardType: TextInputType.emailAddress,
            style: EditEmailPrepaidTheme.fieldValue,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              hintText: '',
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
