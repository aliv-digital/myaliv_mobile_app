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
    return Column(
      children: [
        // ✅ Outer gradient border
        Container(
          width: 280,
          height: 92,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: TopUpPrepaidTheme.amountBorderGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(2), // border thickness
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,

            // ✅ "$" + amount centered together (pixel-ish like figma)
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    r'$',
                    style: TopUpPrepaidTheme.amountText(),
                  ),
                  const SizedBox(width: 6),

                  // ✅ Input only numeric part
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 80,
                      maxWidth: 200,
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (raw) {
                          final cleaned = _sanitize(raw);

                          // ✅ if formatter allowed something odd, normalize quietly
                          if (cleaned != raw) {
                            _controller.value = TextEditingValue(
                              text: cleaned,
                              selection: TextSelection.collapsed(
                                offset: cleaned.length,
                              ),
                            );
                          }

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
        const SizedBox(height: 8),
        Text(
          'enter top up amount',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF222222),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
