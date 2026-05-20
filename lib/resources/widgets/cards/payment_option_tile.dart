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

  const PaymentOptionTile({
    super.key,
    required this.title,
    required this.selected,
    this.onTap,
    this.leading,
    this.titleTrailing,
  });

  static const Color _selectedBg = Color(0xFFEDEAF8);
  static const Color _selectedBorder = Color(0xFF645D9C);
  static const Color _selectedTextColor = Color(0xFF645D9C);
  static const Color _unselectedBg = Colors.white;
  static const Color _unselectedBorder = Color(0xFFE5E7EB);
  static const Color _unselectedTextColor = Color(0xFF1A1A1A);
  static const Color _unselectedRadioBorder = Color(0xFFCFCFCF);

  static const double _tileRadius = 12;
  static const double _tileMinHeight = 64;
  static const double _radioSize = 22;
  static const double _checkIconSize = 14;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(_tileRadius);

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _tileMinHeight - 24),
            child: Row(
              children: [
                if (leading != null) ...[
                  SizedBox(
                    width: 20,
                    height: 40,
                    child: Center(child: leading),
                  ),
                  const SizedBox(width: 12),
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
                _SelectionIndicator(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
        color: selected ? _selectedTextColor : _unselectedTextColor,
        fontSize: 16,
        fontFamily: AppConstants.defaultFontFamily,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: PaymentOptionTile._radioSize,
        height: PaymentOptionTile._radioSize,
        decoration: const BoxDecoration(
          color: PaymentOptionTile._selectedBorder,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check,
          size: PaymentOptionTile._checkIconSize,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: PaymentOptionTile._radioSize,
      height: PaymentOptionTile._radioSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: PaymentOptionTile._unselectedRadioBorder,
          width: 1.5,
        ),
      ),
    );
  }
}
