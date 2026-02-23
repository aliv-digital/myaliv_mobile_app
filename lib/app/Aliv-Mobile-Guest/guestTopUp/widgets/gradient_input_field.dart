import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';

class GradientInputField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const GradientInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return _GradientInputFieldState();
  }
}

class _GradientInputFieldState extends State<GradientInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    _controller.text = GuestTopUpTheme.amountDefaultValue;
  }

  void _handleInputChange(String raw) {
    if (_isFormatting) return;

    final cleaned = _keepDigitsAndDot(raw);
    if (cleaned.isEmpty) {
      _isFormatting = true;
      _controller.clear();
      _isFormatting = false;
      widget.onChanged('');
      return;
    }

    _isFormatting = true;
    _controller.text = '\$$cleaned';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _isFormatting = false;
    widget.onChanged(cleaned);
  }

  String _keepDigitsAndDot(String value) {
    final buffer = StringBuffer();
    for (final codePoint in value.runes) {
      final isDigit = codePoint >= 48 && codePoint <= 57;
      final isDot = codePoint == 46;
      if (isDigit || isDot) {
        buffer.writeCharCode(codePoint);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final innerRadius = GuestTopUpTheme.amountFieldRadius -
        GuestTopUpTheme.amountFieldBorderWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GuestTopUpTheme.amountFieldOuterHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: GuestTopUpTheme.amountHelper,
          ),
          const SizedBox(height: GuestTopUpTheme.amountFieldLabelToFieldGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final startAtTopLeftAngle = math.atan2(
                -GuestTopUpTheme.amountFieldHeight / 2,
                -constraints.maxWidth / 2,
              );

              return SizedBox(
                height: GuestTopUpTheme.amountFieldHeight,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        GuestTopUpTheme.amountFieldRadius),
                    // Anchor gradient start exactly at top-left for
                    // consistent pixel positioning across widths.
                    gradient: SweepGradient(
                      colors: GuestTopUpTheme.amountFieldBorderGradientColors,
                      stops: GuestTopUpTheme.amountFieldBorderGradientStops,
                      transform: GradientRotation(startAtTopLeftAngle),
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: GuestTopUpTheme.amountFieldShadowColor,
                        blurRadius: GuestTopUpTheme.amountFieldShadowBlur,
                        offset:
                            Offset(0, GuestTopUpTheme.amountFieldShadowOffsetY),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        GuestTopUpTheme.amountFieldBorderWidth),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(innerRadius),
                      ),
                      // The editable text area is inset by 68px on both sides
                      // to match the Figma spacing.
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal:
                              GuestTopUpTheme.amountFieldTextHorizontalInset,
                        ),
                        child: Center(
                          child: TextField(
                            controller: _controller,
                            // maxLines: 1,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            style: GuestTopUpTheme.amountInput,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: '\$00',
                              hintStyle: GuestTopUpTheme.amountHint,
                            ),
                            onChanged: _handleInputChange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
