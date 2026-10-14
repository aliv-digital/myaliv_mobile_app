import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/common_switch_button_large.dart';
import '../../theme/top_up_prepaid_theme.dart';

/// Any time toggle section for auto top-up.
class AutoTopupAnyTimeToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AutoTopupAnyTimeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'any time',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        CommonSwitchButtonLarge(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// ATOP-010 confirmation shown before switching the "any time" toggle OFF.
///
/// Mirrors the auto-renew turn-off sheet. Pops with `true` when the user
/// confirms via "ok", and `null` on cancel / back arrow / barrier dismiss.
class AutoTopupTurnOffBottomSheet extends StatelessWidget {
  const AutoTopupTurnOffBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x07101828),
              blurRadius: 8,
              offset: Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x14101828),
              blurRadius: 24,
              offset: Offset(0, 20),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'are you sure you want to turn off auto top-up?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF121212),
                fontSize: 16,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF645D9C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'ok',
                  style: TextStyle(
                    color: Color(0xFFF1F1F8),
                    fontSize: 15,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(color: Color(0xFF645D9C)),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'cancel',
                  style: TextStyle(
                    color: Color(0xFF645D9C),
                    fontSize: 15,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section label widget for auto top-up form.
class AutoTopupSectionLabel extends StatelessWidget {
  final String text;

  const AutoTopupSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
          height: 1.43,
        ),
      ),
    );
  }
}

/// "Or" divider with lines on both sides.
class AutoTopupOrDivider extends StatelessWidget {
  const AutoTopupOrDivider({super.key});

  static const _divider = Expanded(
    child: Divider(height: 1, thickness: 1, color: Color(0xFF8A8A8F)),
  );

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _divider,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              fontFamily: 'CircularPro',
              color: Color(0xFF8A8A8F),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.56,
            ),
          ),
        ),
        _divider,
      ],
    );
  }
}

/// Primary apply button for auto top-up.
class AutoTopupApplyButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const AutoTopupApplyButton({
    super.key,
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF645D9C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text('apply', style: TopUpPrepaidTheme.buttonText()),
      ),
    );
  }
}
