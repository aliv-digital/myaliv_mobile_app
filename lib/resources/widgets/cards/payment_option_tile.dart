import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

/// Radio-style selectable tile used for non-card payment options
/// (pay with card, pay from wallet, no auto-renew, etc.).
///
/// Mirrors the visual language of `SavedCardRadioTile` so all items in a
/// payment-method list look and behave consistently.
class PaymentOptionTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? titleTrailing;

  // Optional visual overrides so callers can keep this tile in lockstep with
  // sibling tiles (e.g. saved-card rows) on the same screen.
  final double? tileRadius;
  final double? radioSize;
  final double? leadingWidth;
  final double? leadingHeight;
  final double leadingToTextGap;
  final EdgeInsetsGeometry? contentPadding;
  final Color? unselectedRadioFill;

  const PaymentOptionTile({
    super.key,
    required this.title,
    required this.selected,
    this.onTap,
    this.leading,
    this.titleTrailing,
    this.tileRadius,
    this.radioSize,
    this.leadingWidth,
    this.leadingHeight,
    this.leadingToTextGap = 0,
    this.contentPadding,
    this.unselectedRadioFill,
  });

  static const Color _selectedBg = Color(0xFFEDEAF8);
  static const Color _selectedBorder = Color(0xFF645D9C);
  static const Color _selectedTextColor = Color(0xFF645D9C);
  static const Color _unselectedBg = Colors.white;
  static const Color _unselectedBorder = Color(0xFFE5E7EB);
  static const Color _unselectedRadioBorder = Color(0xFFCFCFCF);

  static const double _defaultTileRadius = 12;
  static const double _tileMinHeight = 64;
  static const double _defaultRadioSize = 22;
  static const double _defaultLeadingWidth = 20;
  static const double _defaultLeadingHeight = 40;

  @override
  Widget build(BuildContext context) {
    final double tileR = tileRadius ?? _defaultTileRadius;
    final double radioR = radioSize ?? _defaultRadioSize;
    final double leadW = leadingWidth ?? _defaultLeadingWidth;
    final double leadH = leadingHeight ?? _defaultLeadingHeight;
    final BorderRadius radius = BorderRadius.circular(tileR);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? _selectedBg : _unselectedBg,
            borderRadius: radius,
            border: Border.all(
              color: selected ? _selectedBorder : _unselectedBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: contentPadding ??
              const EdgeInsets.only(top: 12, bottom: 12, right: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _tileMinHeight - 24),
            child: Row(
              children: [
                if (leading != null) ...[
                  SizedBox(
                    width: leadW,
                    height: leadH,
                    child: Center(child: leading),
                  ),
                  if (leadingToTextGap > 0) SizedBox(width: leadingToTextGap),
                ],
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(title, style: _titleStyle),
                      ),
                      if (titleTrailing != null) ...[
                        const SizedBox(width: 10),
                        titleTrailing!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SelectionIndicator(
                  selected: selected,
                  size: radioR,
                  unselectedFill: unselectedRadioFill,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
        color: _selectedTextColor,
        fontSize: 16,
        fontFamily: AppConstants.defaultFontFamily,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.selected,
    required this.size,
    this.unselectedFill,
  });

  final bool selected;
  final double size;
  final Color? unselectedFill;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: PaymentOptionTile._selectedBorder,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check,
          size: size * 0.64,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: unselectedFill,
        shape: BoxShape.circle,
        border: Border.all(
          color: PaymentOptionTile._unselectedRadioBorder,
          width: 1.5,
        ),
      ),
    );
  }
}
