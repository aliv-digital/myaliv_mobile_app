import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/rev_confirmation_prepaid_theme.dart';

class RevTermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;

  const RevTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(
              RevConfirmationPrepaidTheme.checkboxCornerRadius,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: RevConfirmationPrepaidTheme.checkboxSize,
              height: RevConfirmationPrepaidTheme.checkboxSize,
              decoration: BoxDecoration(
                color: value
                    ? RevConfirmationPrepaidTheme.checkboxActive
                    : Colors.transparent,
                border: Border.all(
                  color: RevConfirmationPrepaidTheme.checkboxBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  RevConfirmationPrepaidTheme.checkboxCornerRadius,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: RevConfirmationPrepaidTheme.checkboxCheckColor,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: RevConfirmationPrepaidTheme.checkboxToTextGap),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: RevConfirmationPrepaidTheme.terms,
              children: [
                const TextSpan(
                  text: 'By checking this box, I agree to the ',
                ),
                TextSpan(
                  text: 'Terms & Conditions.',
                  style: RevConfirmationPrepaidTheme.link,
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
