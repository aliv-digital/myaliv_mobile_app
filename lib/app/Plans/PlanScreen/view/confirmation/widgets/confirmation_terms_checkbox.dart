import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';

import '../../../../../Aliv-Mobile-Guest/guestPurchasePlanComfirmation/theme/guest_purchase_plan_confirmation_theme.dart';

class ConfirmationTermsCheckbox extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const ConfirmationTermsCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  State<ConfirmationTermsCheckbox> createState() =>
      _ConfirmationTermsCheckboxState();
}

class _ConfirmationTermsCheckboxState extends State<ConfirmationTermsCheckbox> {
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        await showTermsAndConditionsModal(
          context,
          badgeSize: 48,
          badgeInnerSize: 34,
          badgeCoreSize: 24,
          badgeIconWidth: 16,
          badgeIconHeight: 16,
          closeButtonSize: 30,
        );
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onChanged(!widget.isChecked),
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.isChecked
                    ? GuestPurchasePlanConfirmationTheme
                          .termsNoticeCheckboxCheckedFillColor
                    : Colors.transparent,
                border: Border.all(
                  width: 1,
                  color: GuestPurchasePlanConfirmationTheme
                      .termsNoticeCheckboxBorderColor,
                ),
                borderRadius: BorderRadius.circular(
                  GuestPurchasePlanConfirmationTheme.termsNoticeCheckboxRadius,
                ),
              ),
              child: widget.isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: GuestPurchasePlanConfirmationTheme
                          .termsNoticeCheckboxIconSize,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'By checking this box, I agree to the ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                TextSpan(
                  recognizer: _termsRecognizer,
                  text: 'Terms & Conditions.',
                  style: const TextStyle(
                    color: Color(0xFF645D9C),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF645D9C),
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
