import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: GiftDataTheme.sheetBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GiftDataTheme.sheetRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  const Text(
                    'confirm data gift',
                    style: GiftDataTheme.sheetTitle,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SheetRow(
                icon: IconsaxPlusLinear.gift,
                label: 'gift amount',
                value: widget.amountLabel,
              ),
              const _SheetDivider(),
              _SheetRow.leading(
                leading: SvgPicture.asset(
                  AssetConstant.dataIconSVG,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    GiftDataTheme.primaryPurple,
                    BlendMode.srcIn,
                  ),
                ),
                label: 'available to send',
                value: widget.availableLabel,
              ),
              const _SheetDivider(),
              _SheetRow(
                icon: IconsaxPlusLinear.user,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'confirm gift',
                          style: GiftDataTheme.ctaLabel,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required IconData icon,
    required this.label,
    required this.value,
  }) : leading = null,
       _icon = icon;

  const _SheetRow.leading({
    required this.leading,
    required this.label,
    required this.value,
  }) : _icon = null;

  final IconData? _icon;
  final Widget? leading;
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
            child:
                leading ??
                Icon(_icon, size: 20, color: GiftDataTheme.primaryPurple),
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
    return const Divider(height: 1, thickness: 1, color: GiftDataTheme.divider);
  }
}
