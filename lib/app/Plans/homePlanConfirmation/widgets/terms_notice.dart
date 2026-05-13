import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/home_plan_confirmation_theme.dart';

class TermsNotice extends StatefulWidget {
  final bool isChecked;
  final VoidCallback onToggleChecked;
  final VoidCallback onTermsTap;

  const TermsNotice({
    super.key,
    required this.isChecked,
    required this.onToggleChecked,
    required this.onTermsTap,
  });

  @override
  State<TermsNotice> createState() => _TermsNoticeState();
}

class _TermsNoticeState extends State<TermsNotice> {
  late final TapGestureRecognizer _termsTapRecognizer;

  @override
  void initState() {
    super.initState();
    _termsTapRecognizer = TapGestureRecognizer()..onTap = widget.onTermsTap;
  }

  @override
  void didUpdateWidget(covariant TermsNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    _termsTapRecognizer.onTap = widget.onTermsTap;
  }

  @override
  void dispose() {
    _termsTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.onToggleChecked,
          borderRadius: BorderRadius.circular(
            HomePlanConfirmationTheme.termsNoticeCheckboxRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: HomePlanConfirmationTheme.termsNoticeCheckboxTopOffset,
            ),
            child: Container(
              width: HomePlanConfirmationTheme.termsNoticeCheckboxSize,
              height: HomePlanConfirmationTheme.termsNoticeCheckboxSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.isChecked
                    ? HomePlanConfirmationTheme
                          .termsNoticeCheckboxCheckedFillColor
                    : Colors.transparent,
                border: Border.all(
                  width: 1,
                  color:
                      HomePlanConfirmationTheme.termsNoticeCheckboxBorderColor,
                ),
                borderRadius: BorderRadius.circular(
                  HomePlanConfirmationTheme.termsNoticeCheckboxRadius,
                ),
              ),
              child: widget.isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size:
                          HomePlanConfirmationTheme.termsNoticeCheckboxIconSize,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(
          width: HomePlanConfirmationTheme.termsNoticeCheckboxToTextGap,
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HomePlanConfirmationTheme.termsNoticeTextWidth,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'By checking this box, I agree to the ',
                    style: HomePlanConfirmationTheme.termsNoticeBodyTextStyle,
                  ),
                  TextSpan(
                    text: 'Terms & Conditions.',
                    style: HomePlanConfirmationTheme.termsNoticeLinkTextStyle,
                    recognizer: _termsTapRecognizer,
                  ),
                ],
              ),
              textAlign: TextAlign.start,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}
