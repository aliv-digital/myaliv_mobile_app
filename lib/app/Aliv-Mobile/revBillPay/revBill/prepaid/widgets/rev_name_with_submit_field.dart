import 'package:flutter/material.dart';
import '../theme/rev_prepaid_theme.dart';

class RevNameWithSubmitField extends StatefulWidget {
  final String value;
  final String hintText;
  final bool canSubmit;
  final bool submitting;

  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const RevNameWithSubmitField({
    super.key,
    required this.value,
    required this.hintText,
    required this.canSubmit,
    required this.submitting,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  State<RevNameWithSubmitField> createState() => _RevNameWithSubmitFieldState();
}

class _RevNameWithSubmitFieldState extends State<RevNameWithSubmitField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RevNameWithSubmitField oldWidget) {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canTap = widget.canSubmit && !widget.submitting;

    return Stack(
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: RevPrepaidTheme.fieldBg,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.fromLTRB(14, 0, 92, 0), // space for pill
          alignment: Alignment.center,
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            style: RevPrepaidTheme.input,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: RevPrepaidTheme.hintText,
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 8,
          bottom: 8,
          child: Opacity(
            opacity: canTap ? 1 : 0.55,
            child: InkWell(
              onTap: canTap ? widget.onSubmit : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 66,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RevPrepaidTheme.appBarBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.submitting
                    ? const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text('submit', style: RevPrepaidTheme.submit),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
