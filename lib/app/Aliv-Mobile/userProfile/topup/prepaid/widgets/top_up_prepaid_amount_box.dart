import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/top_up_prepaid_theme.dart';

/// Amount input box (Gradient border + centered "$ 15.00" style)
/// - Shows "$" sign visually (not part of the typed value)
/// - Keeps raw numeric value in [value] and returns raw numeric via [onChanged]
class TopUpPrepaidAmountBox extends StatefulWidget {
  final String value; // raw numeric text e.g. "15.00"
  final ValueChanged<String> onChanged;

  const TopUpPrepaidAmountBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TopUpPrepaidAmountBox> createState() => _TopUpPrepaidAmountBoxState();
}

class _TopUpPrepaidAmountBoxState extends State<TopUpPrepaidAmountBox> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant TopUpPrepaidAmountBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ If parent updates value (e.g. from bloc), reflect it without breaking cursor
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      final newText = widget.value;
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _sanitize(String input) {
    // Keep only digits + dot, and allow only one dot
    final only = input.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = only.split('.');
    if (parts.length <= 1) return only;
    return '${parts.first}.${parts.sublist(1).join()}';
  }

  @override
  Widget build(BuildContext context) {
    final innerRadius = (TopUpPrepaidTheme.amountFieldRadius -
            TopUpPrepaidTheme.amountFieldBorderWidth)
        .clamp(0.0, TopUpPrepaidTheme.amountFieldRadius);

    return Container(
      width: TopUpPrepaidTheme.amountFieldWidth,
      height: TopUpPrepaidTheme.amountFieldHeight,
      decoration: BoxDecoration(
        gradient: TopUpPrepaidTheme.amountFieldFocusedBorderGradient,
        borderRadius: BorderRadius.circular(TopUpPrepaidTheme.amountFieldRadius),
      ),
      padding: const EdgeInsets.all(TopUpPrepaidTheme.amountFieldBorderWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Container(
          color: TopUpPrepaidTheme.amountFieldBackground,
          alignment: Alignment.center,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_controller.text.isNotEmpty) ...[
                  Text(
                    r'$',
                    style: TopUpPrepaidTheme.amountText(),
                  ),
                  const SizedBox(
                    width: TopUpPrepaidTheme.amountFieldCurrencyGap,
                  ),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: TopUpPrepaidTheme.amountFieldMinInputWidth,
                    maxWidth: TopUpPrepaidTheme.amountFieldMaxInputWidth,
                  ),
                  child: IntrinsicWidth(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      textAlign: TextAlign.left,
                      style: TopUpPrepaidTheme.amountText(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: r'$00',
                        hintStyle: TopUpPrepaidTheme.amountHint(),
                      ),
                      onChanged: (raw) {
                        final wasEmpty = raw.isEmpty;
                        final cleaned = _sanitize(raw);

                        if (cleaned != raw) {
                          _controller.value = TextEditingValue(
                            text: cleaned,
                            selection: TextSelection.collapsed(
                              offset: cleaned.length,
                            ),
                          );
                        }

                        // Rebuild so the leading "$" toggles with emptiness.
                        if (wasEmpty || cleaned.isEmpty) setState(() {});

                        widget.onChanged(cleaned);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
