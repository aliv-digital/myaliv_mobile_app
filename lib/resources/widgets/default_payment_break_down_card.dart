// default_payment_break_down_card.dart
//
// DefaultPaymentBreakDownCard (Simple API)
// ---------------------------------------
// ✅ Theme-driven (no TextStyle passing)
// ✅ Optional input row (promo / coupon / anything)
// ✅ Figma-like scallops (OVAL + FLAT GAP + exact count)
// ✅ Dashed divider
//
// Usage:
// - without input: just pass items
// - with input: pass input config (value + onChanged + onActionTap)

import 'dart:math' as math;
import 'package:flutter/material.dart';

class PaymentBreakdownLineItem {
  final String label;
  final String value;
  final bool isEmphasized;

  const PaymentBreakdownLineItem({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });
}

class PaymentBreakdownInputConfig {
  /// Current input value (keep this in BLoC state).
  final String value;

  /// Placeholder text (e.g., "promo code")
  final String hintText;

  /// Action text (e.g., "apply")
  final String actionText;

  /// Enable/disable field and action
  final bool enabled;

  /// Called when user types
  final ValueChanged<String>? onChanged;

  /// Called when user taps action (apply)
  final VoidCallback? onActionTap;

  const PaymentBreakdownInputConfig({
    required this.value,
    this.hintText = 'promo code',
    this.actionText = 'apply',
    this.enabled = true,
    this.onChanged,
    this.onActionTap,
  });
}

/// A reusable breakdown card that looks like Figma receipt.
class DefaultPaymentBreakDownCard extends StatelessWidget {
  const DefaultPaymentBreakDownCard({
    super.key,

    // Required
    required this.items,

    // Optional input section
    this.input,

    // Colors (defaults match your figma purple style)
    this.backgroundColor = const Color(0xFF655C9A),
    this.textColor = Colors.white,

    // Shape tuning (keep defaults; override only if design differs)
    this.topCornerRadius = 18,
    this.ovalScallopHeight = 15,
    this.scallopGap = 8,
    this.edgeInset = 0,
    this.targetScallopCount = 12,

    // Spacing (figma-ish defaults)
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 18),
  });

  final List<PaymentBreakdownLineItem> items;
  final PaymentBreakdownInputConfig? input;

  final Color backgroundColor;
  final Color textColor;

  final double topCornerRadius;
  final double ovalScallopHeight;
  final double scallopGap;
  final double edgeInset;
  final int targetScallopCount;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = _BreakdownTheme.defaults(textColor: textColor);

    return PhysicalShape(
      clipper: _OvalScallopBottomClipper(
        topCornerRadius: topCornerRadius,
        ovalHeight: ovalScallopHeight,
        gap: scallopGap,
        edgeInset: edgeInset,
        targetCount: targetScallopCount,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: backgroundColor,
      elevation: 0,
      shadowColor: const Color(0x22000000),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (input != null) ...[
              _InputRow(config: input!, theme: theme),
              const SizedBox(height: 18),
            ],

            // rows
            for (int i = 0; i < items.length; i++) ...[
              _RowItem(item: items[i], theme: theme),
              if (i != items.length - 1) const SizedBox(height: 14),
            ],

            const SizedBox(height: 24),

            const _DashedDivider(
              color: Color(0xB3FFFFFF),
              height: 1,
              dashWidth: 6,
              dashGap: 5,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.item,
    required this.theme,
  });

  final PaymentBreakdownLineItem item;
  final _BreakdownTheme theme;

  @override
  Widget build(BuildContext context) {
    final style = item.isEmphasized ? theme.emphasizedText : theme.normalText;

    return Row(
      children: [
        Expanded(child: Text(item.label, style: style)),
        Text(item.value, style: style),
      ],
    );
  }
}

class _InputRow extends StatefulWidget {
  const _InputRow({
    required this.config,
    required this.theme,
  });

  final PaymentBreakdownInputConfig config;
  final _BreakdownTheme theme;

  @override
  State<_InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<_InputRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.config.value);
  }

  @override
  void didUpdateWidget(covariant _InputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.value != widget.config.value &&
        _controller.text != widget.config.value) {
      _controller.text = widget.config.value;
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
    final c = widget.config;
    final canInteract = c.enabled;

    return Container(
      height: 52,
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
              enabled: canInteract,
              onChanged: c.onChanged,
              style: widget.theme.inputText,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: c.hintText,
                hintStyle: widget.theme.inputHint,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canInteract ? c.onActionTap : null,
            child: Opacity(
              opacity: canInteract ? 1 : 0.45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Text(
                  c.actionText,
                  style: widget.theme.actionText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({
    required this.color,
    required this.height,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double height;
  final double dashWidth;
  final double dashGap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _DashedDividerPainter(
          color: color,
          strokeWidth: height,
          dashWidth: dashWidth,
          dashGap: dashGap,
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  _DashedDividerPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double x = 0;
    final y = size.height / 2;

    while (x < size.width) {
      final x2 = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dashWidth != dashWidth ||
        old.dashGap != dashGap;
  }
}

/// EXACT scallop clipper (your “perfect” approach): OVAL + FLAT GAP + exact count.
class _OvalScallopBottomClipper extends CustomClipper<Path> {
  const _OvalScallopBottomClipper({
    required this.topCornerRadius,
    required this.ovalHeight,
    required this.gap,
    required this.edgeInset,
    required this.targetCount,
  });

  final double topCornerRadius;
  final double ovalHeight;
  final double gap;
  final double edgeInset;
  final int targetCount;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final base = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, w, h),
          topLeft: Radius.circular(topCornerRadius),
          topRight: Radius.circular(topCornerRadius),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      );

    final usableW = (w - 2 * edgeInset).clamp(0.0, w);
    if (usableW <= 0 || ovalHeight <= 0) return base;

    final count = targetCount.clamp(1, 200);
    final ovalWidth = (usableW - (count - 1) * gap) / count;
    if (ovalWidth <= 6) return base;

    final used = (count * ovalWidth) + ((count - 1) * gap);
    final startLeft = edgeInset + (usableW - used) / 2;

    final holes = Path();
    for (int i = 0; i < count; i++) {
      final left = startLeft + i * (ovalWidth + gap);
      final cx = left + ovalWidth / 2;

      holes.addOval(
        Rect.fromCenter(
          center: Offset(cx, h),
          width: ovalWidth,
          height: ovalHeight,
        ),
      );
    }

    return Path.combine(PathOperation.difference, base, holes);
  }

  @override
  bool shouldReclip(covariant _OvalScallopBottomClipper old) {
    return old.topCornerRadius != topCornerRadius ||
        old.ovalHeight != ovalHeight ||
        old.gap != gap ||
        old.edgeInset != edgeInset ||
        old.targetCount != targetCount;
  }
}

/// Internal theme defaults (keeps usage simple).
class _BreakdownTheme {
  final TextStyle normalText;
  final TextStyle emphasizedText;

  final TextStyle inputHint;
  final TextStyle inputText;
  final TextStyle actionText;

  const _BreakdownTheme({
    required this.normalText,
    required this.emphasizedText,
    required this.inputHint,
    required this.inputText,
    required this.actionText,
  });

  factory _BreakdownTheme.defaults({required Color textColor}) {
    const font = 'CircularPro';

    return _BreakdownTheme(
      normalText: TextStyle(
        fontFamily: font,
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.1,
      ),
      emphasizedText: TextStyle(
        fontFamily: font,
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
      inputHint: const TextStyle(
        fontFamily: font,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: Color(0xFFD0D0D0),
      ),
      inputText: const TextStyle(
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: Color(0xFF655C9A),
      ),
      actionText: const TextStyle(
        fontFamily: font,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: Color(0xFF655C9A),
      ),
    );
  }
}
