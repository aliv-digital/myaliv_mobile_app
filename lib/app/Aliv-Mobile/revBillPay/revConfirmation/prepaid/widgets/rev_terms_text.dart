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
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: RevConfirmationPrepaidTheme.checkboxBorder,
              width: 1.2,
            ),
            activeColor: RevConfirmationPrepaidTheme.checkboxActive,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            // checkbox height এর সাথে text baseline align করার জন্য
            padding: const EdgeInsets.only(top: 2),
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
        ),
      ],
    );
  }
}
