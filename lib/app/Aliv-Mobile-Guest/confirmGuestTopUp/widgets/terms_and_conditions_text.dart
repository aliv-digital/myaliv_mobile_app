import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({
    super.key,
    required this.onTapTerms,
    required this.isChecked,
    required this.onToggleChecked,
  });

  final VoidCallback onTapTerms;
  final bool isChecked;
  final VoidCallback onToggleChecked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: TopUpConfirmTheme.termsTopInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: TopUpConfirmTheme.termsCheckboxTopOffset,
            ),
            child: GestureDetector(
              onTap: onToggleChecked,
              child: Container(
                width: TopUpConfirmTheme.termsCheckboxSize,
                height: TopUpConfirmTheme.termsCheckboxSize,
                decoration: BoxDecoration(
                  color: isChecked
                      ? TopUpConfirmTheme.termsCheckboxColor
                      : TopUpConfirmTheme.termsCheckboxUncheckedBackgroundColor,
                  borderRadius: BorderRadius.circular(
                    TopUpConfirmTheme.termsCheckboxRadius,
                  ),
                  border: Border.all(
                    color: TopUpConfirmTheme.termsCheckboxBorderColor,
                    width: TopUpConfirmTheme.termsCheckboxBorderWidth,
                  ),
                ),
                alignment: Alignment.center,
                child: isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        color: TopUpConfirmTheme.termsCheckboxCheckIconColor,
                        size: TopUpConfirmTheme.termsCheckboxIconSize,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: TopUpConfirmTheme.termsCheckboxToTextGap),
          Expanded(
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TopUpConfirmTheme.termsLead,
                children: [
                  TextSpan(
                    style: TopUpConfirmTheme.termsLead,
                    text: TopUpConfirmTheme.termsLeadText,
                  ),
                  TextSpan(
                    text: TopUpConfirmTheme.termsLinkText,
                    style: TopUpConfirmTheme.termsLink,
                    recognizer: TapGestureRecognizer()..onTap = onTapTerms,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
