import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../theme/purchase_add_ons_theme.dart';

/// Red primary-plan card copied from the PlanScreen add-ons UI.
///
/// The API gives us the active primary plan, and this card presents the same
/// plan name, active date, expire date, and auto-renew affordance used there.
class PurchaseAddOnsPlanRedImageCard extends StatelessWidget {
  const PurchaseAddOnsPlanRedImageCard({
    super.key,
    required this.planLabel,
    required this.planName,
    required this.activeLabel,
    required this.activeDate,
    required this.expireLabel,
    required this.expireDate,
    this.autoRenew = true,
    this.onAutoRenewChanged,
    this.topRight,
    this.maxWidth = 380,
    this.height = 150,
    this.borderRadius = 12,
  });

  final String planLabel;
  final String planName;
  final String activeLabel;
  final String activeDate;
  final String expireLabel;
  final String expireDate;
  final bool autoRenew;
  final ValueChanged<bool>? onAutoRenewChanged;
  final Widget? topRight;

  final double maxWidth;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AssetConstant.planRedCardPNG,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: PurchaseAddOnsTheme.planRed),
                ),
                Padding(
                  padding: PurchaseAddOnsTheme.planRedCardContentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            planLabel,
                            style: PurchaseAddOnsTheme.t(
                              12,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (topRight != null)
                            topRight!
                          else
                            _AutoRenewSection(
                              value: autoRenew,
                              onChanged: onAutoRenewChanged,
                            ),
                        ],
                      ),
                      Text(
                        planName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PurchaseAddOnsTheme.t(
                          24,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _DateBlock(
                            label: activeLabel,
                            value: activeDate,
                            alignEnd: false,
                          ),
                          const Spacer(),
                          _DateBlock(
                            label: expireLabel,
                            value: expireDate,
                            alignEnd: true,
                          ),
                        ],
                      ),
                    ],
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

class _AutoRenewSection extends StatelessWidget {
  const _AutoRenewSection({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AutoRenewToggle(value: value, onChanged: onChanged),
        const SizedBox(width: 8),
        const Text(
          'auto renew',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w400,
            fontVariations: <FontVariation>[FontVariation('wght', 450)],
          ),
        ),
      ],
    );
  }
}

class _AutoRenewToggle extends StatefulWidget {
  const _AutoRenewToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const Color _toggleBorder = Color(0xFFDCDCDC);
  static const Color _toggleOnColor = Color(0xFF645D9C);
  static const Color _toggleOffColor = Color(0xFFEDECF6);

  @override
  State<_AutoRenewToggle> createState() => _AutoRenewToggleState();
}

class _AutoRenewToggleState extends State<_AutoRenewToggle> {
  late bool _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant _AutoRenewToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _localValue = widget.value;
    }
  }

  void _handleTap() {
    final bool next = !_localValue;
    if (widget.onChanged != null) {
      widget.onChanged!(next);
      return;
    }
    setState(() {
      _localValue = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool value = _localValue;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 5.666),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _AutoRenewToggle._toggleBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.5),
            child: Text(
              value ? 'on' : 'off',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 16.67,
            height: 16.67,
            decoration: BoxDecoration(
              color: value
                  ? _AutoRenewToggle._toggleOnColor
                  : _AutoRenewToggle._toggleOffColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              value ? Icons.check : Icons.close,
              size: 12,
              color: value ? Colors.white : _AutoRenewToggle._toggleOnColor,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(999),
        child: child,
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.label,
    required this.value,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: PurchaseAddOnsTheme.t(
            12,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: PurchaseAddOnsTheme.t(
            15,
            weight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
          ).copyWith(letterSpacing: 2.25),
        ),
      ],
    );
  }
}
