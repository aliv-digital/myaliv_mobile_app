import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/theme/app_theme.dart';

/// CustomPaymentBreakDownCard
/// -------------------------
/// Reusable receipt/payment-breakdown card with optional promo row.
///
/// Usage 1: Basic breakdown (no promo row)
/// ```dart
/// CustomPaymentBreakDownCard(
///   items: const [
///     CustomPaymentBreakdownLineItem(label: 'sub total', value: r'$ 75.00'),
///     CustomPaymentBreakdownLineItem(label: 'vat', value: r'$ 0.00'),
///     CustomPaymentBreakdownLineItem(label: 'total', value: r'$ 75.00'),
///   ],
/// )
/// ```
///
/// Usage 2: Breakdown with promo input/action
/// ```dart
/// CustomPaymentBreakDownCard(
///   input: CustomPaymentBreakdownInputConfig(
///     value: promoCode,
///     hintText: 'promo code',
///     actionText: 'apply',
///     enabled: !isApplyingPromo,
///     onChanged: (v) => context.read<MyBloc>().add(PromoChanged(v)),
///     onActionTap: () => context.read<MyBloc>().add(const ApplyPromoPressed()),
///   ),
///   items: [
///     CustomPaymentBreakdownLineItem(
///       label: 'subtotal',
///       value: '\$ ${subTotal.toStringAsFixed(2)}',
///     ),
///     CustomPaymentBreakdownLineItem(
///       label: 'vat',
///       value: '\$ ${vat.toStringAsFixed(2)}',
///     ),
///     CustomPaymentBreakdownLineItem(
///       label: 'total',
///       value: '\$ ${total.toStringAsFixed(2)}',
///     ),
///   ],
/// )
/// ```
///
/// Optional customization:
/// - `backgroundColor`, `textColor`, `padding`
/// - `topCornerRadius`, scallop options (`scallopCount`, `scallopDepth`, etc.)
/// - divider behavior (`showDivider`, `placeDividerBeforeLastItem`)
/// - row typography (`rowTextStyle`, `emphasizedRowTextStyle`)
///  created by : Nahin | 12-02-2026
class CustomPaymentBreakdownLineItem {
  const CustomPaymentBreakdownLineItem({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;
}

class CustomPaymentBreakdownInputConfig {
  const CustomPaymentBreakdownInputConfig({
    required this.value,
    this.hintText = 'promo code',
    this.actionText = 'apply',
    this.enabled = true,
    this.onChanged,
    this.onActionTap,
    this.textStyle,
    this.hintStyle,
    this.actionStyle,
    this.height = AppTheme.paymentBreakdownPromoHeight,
    this.padding = AppTheme.paymentBreakdownPromoPadding,
    this.backgroundColor = AppTheme.paymentBreakdownPromoBackgroundColor,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppTheme.paymentBreakdownPromoRadius),
    ),
    this.actionGap = AppTheme.paymentBreakdownPromoActionGap,
  });

  final String value;
  final String hintText;
  final String actionText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onActionTap;

  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? actionStyle;

  final double height;
  final EdgeInsets padding;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final double actionGap;
}

class CustomPaymentBreakDownCard extends StatelessWidget {
  const CustomPaymentBreakDownCard({
    super.key,
    required this.items,
    this.input,
    this.showDivider = true,
    this.placeDividerBeforeLastItem = true,
    this.backgroundColor = AppTheme.paymentBreakdownCardBackgroundColor,
    this.textColor = AppTheme.paymentBreakdownCardTextColor,
    this.padding = AppTheme.paymentBreakdownCardPadding,
    this.topCornerRadius = AppTheme.paymentBreakdownCardTopCornerRadius,
    this.elevation = AppTheme.paymentBreakdownCardElevation,
    this.shadowColor = AppTheme.paymentBreakdownCardShadowColor,
    this.scallopCount = AppTheme.paymentBreakdownScallopCount,
    this.scallopGap = AppTheme.paymentBreakdownScallopGap,
    this.scallopDepth = AppTheme.paymentBreakdownScallopDepth,
    this.scallopSideInset = AppTheme.paymentBreakdownScallopSideInset,
    this.scallopOvalHeightFactor =
        AppTheme.paymentBreakdownScallopOvalHeightFactor,
    this.rowGap = AppTheme.paymentBreakdownRowGap,
    this.gapBeforeDivider = AppTheme.paymentBreakdownGapBeforeDivider,
    this.gapAfterDivider = AppTheme.paymentBreakdownGapAfterDivider,
    this.bottomInnerGap = AppTheme.paymentBreakdownBottomInnerGap,
    this.dividerColor = AppTheme.paymentBreakdownCardDividerColor,
    this.dividerHeight = AppTheme.paymentBreakdownDividerHeight,
    this.dividerDashWidth = AppTheme.paymentBreakdownDividerDashWidth,
    this.dividerDashGap = AppTheme.paymentBreakdownDividerDashGap,
    this.promoBottomGap = AppTheme.paymentBreakdownPromoBottomGap,
    this.rowTextStyle,
    this.emphasizedRowTextStyle,
  });

  final List<CustomPaymentBreakdownLineItem> items;
  final CustomPaymentBreakdownInputConfig? input;

  final bool showDivider;
  final bool placeDividerBeforeLastItem;

  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;

  final double topCornerRadius;
  final double elevation;
  final Color shadowColor;

  final int scallopCount;
  final double scallopGap;
  final double scallopDepth;
  final double scallopSideInset;
  final double scallopOvalHeightFactor;

  final double rowGap;
  final double gapBeforeDivider;
  final double gapAfterDivider;
  final double bottomInnerGap;

  final Color dividerColor;
  final double dividerHeight;
  final double dividerDashWidth;
  final double dividerDashGap;

  final double promoBottomGap;

  final TextStyle? rowTextStyle;
  final TextStyle? emphasizedRowTextStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedRowText =
        (rowTextStyle ?? AppTheme.paymentBreakdownRowText).copyWith(
      color: textColor,
    );
    final resolvedEmphasizedText =
        (emphasizedRowTextStyle ?? AppTheme.paymentBreakdownEmphasizedRowText)
            .copyWith(color: textColor);

    return PhysicalShape(
      clipper: _CustomScallopBottomClipper(
        cornerRadius: topCornerRadius,
        scallopCount: scallopCount,
        scallopGap: scallopGap,
        scallopDepth: scallopDepth,
        scallopSideInset: scallopSideInset,
        scallopOvalHeightFactor: scallopOvalHeightFactor,
      ),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (input != null) ...[
              _CustomPromoInputRow(config: input!),
              SizedBox(height: promoBottomGap),
            ],
            if (placeDividerBeforeLastItem &&
                showDivider &&
                items.length > 1) ...[
              for (int i = 0; i < items.length - 1; i++) ...[
                _CustomBreakdownRow(
                  item: items[i],
                  textStyle: resolvedRowText,
                  emphasizedTextStyle: resolvedEmphasizedText,
                ),
                if (i != items.length - 2) SizedBox(height: rowGap),
              ],
              SizedBox(height: gapBeforeDivider),
              _CustomDashedDivider(
                color: dividerColor,
                height: dividerHeight,
                dashWidth: dividerDashWidth,
                dashGap: dividerDashGap,
              ),
              SizedBox(height: gapAfterDivider),
              _CustomBreakdownRow(
                item: items.last,
                textStyle: resolvedRowText,
                emphasizedTextStyle: resolvedEmphasizedText,
              ),
              SizedBox(height: bottomInnerGap),
            ] else ...[
              for (int i = 0; i < items.length; i++) ...[
                _CustomBreakdownRow(
                  item: items[i],
                  textStyle: resolvedRowText,
                  emphasizedTextStyle: resolvedEmphasizedText,
                ),
                if (i != items.length - 1) SizedBox(height: rowGap),
              ],
              if (showDivider) ...[
                SizedBox(height: gapBeforeDivider),
                _CustomDashedDivider(
                  color: dividerColor,
                  height: dividerHeight,
                  dashWidth: dividerDashWidth,
                  dashGap: dividerDashGap,
                ),
                SizedBox(height: gapAfterDivider),
              ],
              SizedBox(height: bottomInnerGap),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomBreakdownRow extends StatelessWidget {
  const _CustomBreakdownRow({
    required this.item,
    required this.textStyle,
    required this.emphasizedTextStyle,
  });

  final CustomPaymentBreakdownLineItem item;
  final TextStyle textStyle;
  final TextStyle emphasizedTextStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = item.isEmphasized ? emphasizedTextStyle : textStyle;

    return Row(
      children: [
        Expanded(child: Text(item.label, style: resolvedStyle)),
        Text(item.value, style: resolvedStyle),
      ],
    );
  }
}

class _CustomPromoInputRow extends StatefulWidget {
  const _CustomPromoInputRow({required this.config});

  final CustomPaymentBreakdownInputConfig config;

  @override
  State<_CustomPromoInputRow> createState() => _CustomPromoInputRowState();
}

class _CustomPromoInputRowState extends State<_CustomPromoInputRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.config.value);
  }

  @override
  void didUpdateWidget(covariant _CustomPromoInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.value != widget.config.value &&
        _controller.text != widget.config.value) {
      _controller.text = widget.config.value;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final canInteract = config.enabled;

    return Container(
      height: config.height,
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: config.borderRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: canInteract,
              onChanged: config.onChanged,
              style: config.textStyle ?? AppTheme.paymentBreakdownPromoText,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: config.hintText,
                hintStyle:
                    config.hintStyle ?? AppTheme.paymentBreakdownPromoHint,
              ),
            ),
          ),
          SizedBox(width: config.actionGap),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canInteract ? config.onActionTap : null,
            child: Opacity(
              opacity: canInteract
                  ? 1
                  : AppTheme.paymentBreakdownPromoDisabledOpacity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Text(
                  config.actionText,
                  style: config.actionStyle ??
                      AppTheme.paymentBreakdownPromoAction,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDashedDivider extends StatelessWidget {
  const _CustomDashedDivider({
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
        painter: _CustomDashedDividerPainter(
          color: color,
          strokeWidth: height,
          dashWidth: dashWidth,
          dashGap: dashGap,
        ),
      ),
    );
  }
}

class _CustomDashedDividerPainter extends CustomPainter {
  _CustomDashedDividerPainter({
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
  bool shouldRepaint(covariant _CustomDashedDividerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

class _CustomScallopBottomClipper extends CustomClipper<Path> {
  const _CustomScallopBottomClipper({
    required this.cornerRadius,
    required this.scallopCount,
    required this.scallopGap,
    required this.scallopDepth,
    required this.scallopSideInset,
    required this.scallopOvalHeightFactor,
  });

  final double cornerRadius;
  final int scallopCount;
  final double scallopGap;
  final double scallopDepth;
  final double scallopSideInset;
  final double scallopOvalHeightFactor;

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, size.height),
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
        ),
      );

    final leftLimit = scallopSideInset;
    final rightLimit = size.width - scallopSideInset;
    final usableWidth = (rightLimit - leftLimit).clamp(0.0, size.width);

    final count = scallopCount.clamp(1, 9999);
    final totalGap = (count - 1) * scallopGap;
    final diameter = ((usableWidth - totalGap) / count).clamp(0.0, usableWidth);
    final ovalHeight = diameter * scallopOvalHeightFactor;

    final radiusX = diameter / 2;
    final radiusY = ovalHeight / 2;
    if (radiusX <= 0 || radiusY <= 0) {
      return base;
    }

    final step = diameter + scallopGap;
    final startX = leftLimit + radiusX;

    final depth = scallopDepth.clamp(0.0, radiusY);
    final centerYOffset = radiusY - depth;
    final centerY = size.height + centerYOffset;

    final holes = Path();
    for (int i = 0; i < count; i++) {
      final cx = startX + i * step;
      holes.addOval(
        Rect.fromCenter(
          center: Offset(cx, centerY),
          width: diameter,
          height: ovalHeight,
        ),
      );
    }

    return Path.combine(PathOperation.difference, base, holes);
  }

  @override
  bool shouldReclip(covariant _CustomScallopBottomClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.scallopCount != scallopCount ||
        oldClipper.scallopGap != scallopGap ||
        oldClipper.scallopDepth != scallopDepth ||
        oldClipper.scallopSideInset != scallopSideInset ||
        oldClipper.scallopOvalHeightFactor != scallopOvalHeightFactor;
  }
}
