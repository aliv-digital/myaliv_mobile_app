import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/top_up_prepaid_theme.dart';

/// Amount input box with the currency symbol and digits centered together.
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
    final inputStyle = Theme.of(context).textTheme.bodyLarge!;
    final amountStyle = inputStyle
        .merge(TopUpPrepaidTheme.amountText())
        .copyWith(letterSpacing: 0);
    final hintStyle = inputStyle
        .merge(TopUpPrepaidTheme.amountHint())
        .copyWith(letterSpacing: 0);
    const hint = r'$0.00';
    const cursorWidth = 2.0;
    // EditableText reserves a one-pixel gap in addition to the cursor width.
    const cursorSpace = cursorWidth + 1;
    // Measure with the same effective style as TextField so inherited letter
    // spacing cannot shift the digits as the amount gets longer.
    final textPainter = TextPainter(
      text: TextSpan(
        text: isEmpty ? hint : _controller.text,
        style: isEmpty ? hintStyle : amountStyle,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final inputWidth = (textPainter.width + cursorSpace).clamp(
      cursorSpace,
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
                // Balance the invisible cursor space so the visible amount,
                // including its currency symbol, is centered in the box.
                const SizedBox(width: cursorSpace),
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
                    textAlignVertical: TextAlignVertical.center,
                    cursorWidth: cursorWidth,
                    style: amountStyle,
                    strutStyle: StrutStyle.disabled,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
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

                      // Refit the centered amount after every edit.
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
