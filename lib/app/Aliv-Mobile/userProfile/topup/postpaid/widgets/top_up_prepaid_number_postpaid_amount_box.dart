import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import '../theme/top_up_prepaid_number_postpaid_theme.dart';

/// ✅ Gradient bordered amount box with fixed "$" prefix.
/// ✅ "$" + amount visually centered together (pixel-perfect)
/// - Keeps TextEditingController (no cursor jump)
/// - Input accepts digits + dot
class TopUpPrepaidNumberPostPaidAmountBox extends StatefulWidget {
  final String value; // numeric string like "0.00"
  final ValueChanged<String> onChanged;

  const TopUpPrepaidNumberPostPaidAmountBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TopUpPrepaidNumberPostPaidAmountBox> createState() =>
      _TopUpPrepaidNumberPostPaidAmountBoxState();
}

class _TopUpPrepaidNumberPostPaidAmountBoxState
    extends State<TopUpPrepaidNumberPostPaidAmountBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(
    covariant TopUpPrepaidNumberPostPaidAmountBox oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    // ✅ external state update -> update controller safely
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
    // ✅ rebuild so calculated width updates as user types
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  double _measureTextWidth(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    final amountStyle = TopUpPrepaidNumberPostPaidTheme.amountText();
    final hintStyle = amountStyle.copyWith(
      color: amountStyle.color?.withValues(alpha: 0.35),
    );
    final isEmpty = _controller.text.isEmpty;

    // ✅ measure current typed amount (controller is source of truth while editing).
    // When empty, size to the hint text so the placeholder fits.
    final currentText = isEmpty ? r'$00' : _controller.text;

    // ✅ dynamic width so "$" + amount can be perfectly centered
    final textWidth = _measureTextWidth(currentText, amountStyle);

    // tune these if needed to match figma tighter/looser
    const maxFieldWidth = 220.0;

    // Hug the measured text/hint width so a single digit doesn't float in a
    // wider centered field, but the "$00" hint still fits (currentText above
    // falls back to r'$00' when empty).
    final fieldWidth = (textWidth + 4).clamp(14.0, maxFieldWidth);

    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'enter top-up amount',
          style: TopUpPrepaidNumberPostPaidTheme.amountHint(),
        ),
        const SizedBox(height: 8),

        Container(
          width: 280,
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              GuestTopUpTheme.amountFieldRadius,
            ),
            // Anchor gradient start exactly at top-left for
            // consistent pixel positioning across widths.
            gradient: SweepGradient(
              colors: GuestTopUpTheme.amountFieldBorderGradientColors,
              stops: GuestTopUpTheme.amountFieldBorderGradientStops,
              transform: GradientRotation(60),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: GuestTopUpTheme.amountFieldShadowColor,
                blurRadius: GuestTopUpTheme.amountFieldShadowBlur,
                offset: Offset(0, GuestTopUpTheme.amountFieldShadowOffsetY),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Center(
              // ✅ makes the whole "$ + amount" group centered inside the box
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isEmpty) Text(r'$', style: amountStyle),
                  SizedBox(
                    width: fieldWidth,
                    child: TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      style: amountStyle,
                      textAlign: TextAlign.center,
                      // ✅ visually centered
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: r'$00',
                        hintStyle: hintStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Text(
        //   'enter top up amount',
        //   style: TopUpPrepaidNumberPostPaidTheme.amountHint(),
        // ),
      ],
    );
  }
}
