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
    final isEmpty = _controller.text.isEmpty;
    final amountStyle = TopUpPrepaidTheme.amountText();
    final hintStyle = TopUpPrepaidTheme.amountHint();
    const hint = r'$0.00';
    const cursorWidth = 2.0;
    // Size the editable value explicitly: intrinsic input/hint widths must
    // not contribute invisible space to the centered currency/value group.
    final textPainter = TextPainter(
      text: TextSpan(
        text: isEmpty ? hint : _controller.text,
        style: DefaultTextStyle.of(
          context,
        ).style.merge(isEmpty ? hintStyle : amountStyle),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final inputWidth = (textPainter.width + cursorWidth).clamp(
      cursorWidth,
      TopUpPrepaidTheme.amountFieldMaxInputWidth,
    );
    textPainter.dispose();
    final innerRadius =
        (TopUpPrepaidTheme.amountFieldRadius -
                TopUpPrepaidTheme.amountFieldBorderWidth)
            .clamp(0.0, TopUpPrepaidTheme.amountFieldRadius);

    return Container(
      width: TopUpPrepaidTheme.amountFieldWidth,
      height: TopUpPrepaidTheme.amountFieldHeight,
      decoration: BoxDecoration(
        gradient: TopUpPrepaidTheme.amountFieldFocusedBorderGradient,
        borderRadius: BorderRadius.circular(
          TopUpPrepaidTheme.amountFieldRadius,
        ),
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
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (!isEmpty) ...[
                  Text(r'$', style: amountStyle),
                  const SizedBox(
                    width: TopUpPrepaidTheme.amountFieldCurrencyGap,
                  ),
                ],
                SizedBox(
                  width: inputWidth,
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
                    cursorWidth: cursorWidth,
                    style: amountStyle,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: isEmpty ? hint : null,
                      hintStyle: hintStyle,
                    ),
                    onChanged: (raw) {
                      final cleaned = _sanitize(raw);

                      if (cleaned != raw) {
                        _controller.value = TextEditingValue(
                          text: cleaned,
                          selection: TextSelection.collapsed(
                            offset: cleaned.length,
                          ),
                        );
                      }

                      // Refit the currency/value group after every edit.
                      setState(() {});

                      widget.onChanged(cleaned);
                    },
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
