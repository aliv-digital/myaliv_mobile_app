import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// "confirm data gift" bottom sheet — screen 2 in the flow.
/// Returns `true` from [show] when the user taps "confirm gift".
class ConfirmGiftBottomSheet extends StatelessWidget {
  const ConfirmGiftBottomSheet._({
    required this.amountLabel,
    required this.availableLabel,
    required this.recipient,
    required this.submitting,
  });

  final String amountLabel;
  final String availableLabel;
  final String recipient;
  final bool submitting;

  static Future<bool> show(
    BuildContext context, {
    required String amountLabel,
    required String availableLabel,
    required String recipient,
    required Future<bool> Function() onConfirm,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (sheetContext) {
        return _ConfirmGiftBottomSheetScaffold(
          amountLabel: amountLabel,
          availableLabel: availableLabel,
          recipient: recipient,
          onConfirm: onConfirm,
        );
      },
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _ConfirmGiftBottomSheetScaffold extends StatefulWidget {
  const _ConfirmGiftBottomSheetScaffold({
    required this.amountLabel,
    required this.availableLabel,
    required this.recipient,
    required this.onConfirm,
  });

  final String amountLabel;
  final String availableLabel;
  final String recipient;
  final Future<bool> Function() onConfirm;

  @override
  State<_ConfirmGiftBottomSheetScaffold> createState() =>
      _ConfirmGiftBottomSheetScaffoldState();
}

class _ConfirmGiftBottomSheetScaffoldState
    extends State<_ConfirmGiftBottomSheetScaffold> {
  bool _submitting = false;

  Future<void> _handleConfirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final ok = await widget.onConfirm();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: GiftDataTheme.sheetBg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GiftDataTheme.sheetRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: back arrow + title
            Row(
              children: [
                InkResponse(
                  onTap: () => Navigator.of(context).pop(false),
                  radius: 20,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: GiftDataTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('confirm data gift', style: GiftDataTheme.sheetTitle),
              ],
            ),
            const SizedBox(height: 16),
            _SheetRow(
              icon: AssetConstant.giftBoxSVG,
              iconColor: GiftDataTheme.primaryPurple,
              label: 'gift amount',
              value: widget.amountLabel,
            ),
            const _SheetDivider(),
            _SheetRow(
              icon: AssetConstant.wifiIconSVG,
              iconColor: GiftDataTheme.accentOrange,
              label: 'available to send',
              value: widget.availableLabel,
            ),
            const _SheetDivider(),
            _SheetRow(
              icon: null,
              fallbackIcon: Icons.person_outline,
              iconColor: GiftDataTheme.textGreyLabel,
              label: 'recipient',
              value: widget.recipient,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: GiftDataTheme.ctaHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftDataTheme.primaryPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: _submitting ? null : _handleConfirm,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('confirm gift', style: GiftDataTheme.ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.fallbackIcon,
  });

  final String? icon;
  final IconData? fallbackIcon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: icon != null
                ? SvgPicture.asset(
                    icon!,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    placeholderBuilder: (_) => Icon(
                      fallbackIcon ?? Icons.circle_outlined,
                      size: 20,
                      color: iconColor,
                    ),
                  )
                : Icon(fallbackIcon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GiftDataTheme.sheetRowLabel)),
          Text(value, style: GiftDataTheme.sheetRowValue),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: GiftDataTheme.divider,
    );
  }
}
