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
        child: Text(
          'apply',
          style: TopUpPrepaidTheme.buttonText(),
        ),
      ),
    );
  }
}
