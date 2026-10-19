import 'package:flutter/material.dart';
import '../theme/rev_confirmation_prepaid_theme.dart';

class RevPromoCodeField extends StatefulWidget {
  final String value;
  final bool canApply;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;

  const RevPromoCodeField({
    super.key,
    required this.value,
    required this.canApply,
    required this.onApply,
    required this.onChanged,
  });

  @override
  State<RevPromoCodeField> createState() => _RevPromoCodeFieldState();
}

class _RevPromoCodeFieldState extends State<RevPromoCodeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant RevPromoCodeField oldWidget) {
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
    final canTap = widget.canApply;

    return Container(
      height: 52, // ✅ figma-like
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: const TextStyle(
                fontFamily: RevConfirmationPrepaidTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: RevConfirmationPrepaidTheme.appBarBg,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'promo code',
                hintStyle: TextStyle(
                  fontFamily: RevConfirmationPrepaidTheme.fontFamily,
                  fontSize: 18, // ✅ smaller than your current
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: Color(0xFFD0D0D0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canTap ? widget.onApply : null,
            child: Opacity(
              opacity: canTap ? 1 : 0.55,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Text(
                  'apply',
                  style: TextStyle(
                    fontFamily: RevConfirmationPrepaidTheme.fontFamily,
                    fontSize: 16, // ✅ figma-like
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: RevConfirmationPrepaidTheme.appBarBg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
