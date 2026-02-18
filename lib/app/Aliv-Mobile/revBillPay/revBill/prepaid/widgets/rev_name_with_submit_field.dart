import 'package:flutter/material.dart';
import '../../../../login/widgets/focused_input_border_wrapper.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChanged);
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
    final canTap = widget.canSubmit && !widget.submitting;

    return SizedBox(
      height: RevPrepaidTheme.inputFieldHeight,
      child: FocusedInputBorderWrapper(
        isFocused: _hasFocus,
        unfocusedBorderColor: RevPrepaidTheme.inputFieldBorderColor,
        radius: RevPrepaidTheme.inputFieldRadius,
        borderWidth: RevPrepaidTheme.inputFieldBorderWidth,
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: RevPrepaidTheme.fieldBg,
                borderRadius:
                    BorderRadius.circular(RevPrepaidTheme.inputFieldRadius),
              ),
              padding:
                  const EdgeInsets.fromLTRB(14, 0, 92, 0), // space for pill
              alignment: Alignment.center,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
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
                opacity: canTap ? 1 : 1, // 0.55, // activate moment , initially inactive
                child: InkWell(
                  onTap: canTap ? widget.onSubmit : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    //width: ,
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: RevPrepaidTheme.appBarBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    // child: widget.submitting ? const SizedBox(
                    //   height: 4,
                    //   width: 4,
                    //   child: CircularProgressIndicator(strokeWidth: 1)
                    // ) : Text('submit', style: RevPrepaidTheme.submit),
                    child: Text('submit', style: RevPrepaidTheme.submit),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
