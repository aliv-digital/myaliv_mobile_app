import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_confirm_theme.dart';

class GuestPayBillConfirmTermsRow extends StatelessWidget {
  const GuestPayBillConfirmTermsRow({
    super.key,
    required this.isChecked,
    required this.onToggleChecked,
    required this.onTapTerms,
  });

  final bool isChecked;
  final VoidCallback onToggleChecked;
  final VoidCallback onTapTerms;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleChecked,
            child: Padding(
              padding: const EdgeInsets.only(
                top: GuestPayBillConfirmTheme.termsCheckboxTopInset,
              ),
              child: Container(
                width: GuestPayBillConfirmTheme.termsCheckboxSize,
                height: GuestPayBillConfirmTheme.termsCheckboxSize,
                decoration: BoxDecoration(
                  color: isChecked
                      ? GuestPayBillConfirmTheme.termsCheckboxFillColor
                      : GuestPayBillConfirmTheme.termsCheckboxUncheckedColor,
                  borderRadius: BorderRadius.circular(
                    GuestPayBillConfirmTheme.termsCheckboxRadius,
                  ),
                  border: Border.all(
                    color: GuestPayBillConfirmTheme.termsCheckboxBorderColor,
                    width: GuestPayBillConfirmTheme.termsCheckboxBorderWidth,
                  ),
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: GuestPayBillConfirmTheme.termsCheckboxCheckSize,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(
              width: GuestPayBillConfirmTheme.termsCheckboxToTextGap),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapTerms,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: GuestPayBillConfirmTheme.termsPrefix,
                      style: GuestPayBillConfirmTheme.termsBase,
                    ),
                    const TextSpan(
                      text: GuestPayBillConfirmTheme.termsLinkText,
                      style: GuestPayBillConfirmTheme.termsLink,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
