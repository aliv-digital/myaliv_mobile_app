import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/make_payment_postpaid_theme.dart';

class MpTermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;

  const MpTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 15,
          height: 15,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            side: BorderSide(
              color: MakePaymentPostPaidTheme.optionSelectedBorder,
              width: 1.2,
            ),
            activeColor: MakePaymentPostPaidTheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RichText(
              text: TextSpan(
                style: MakePaymentPostPaidTheme.termsText,
                children: [
                  const TextSpan(
                    text: 'By checking this box, I agree to the ',
                  ),
                  TextSpan(
                    text: 'Terms & Conditions.',
                    style: MakePaymentPostPaidTheme.termsLink,
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
