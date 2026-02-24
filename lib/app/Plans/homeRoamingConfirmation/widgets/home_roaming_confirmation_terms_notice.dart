import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/home_roaming_confirmation_theme.dart';

class HomeRoamingConfirmationTermsNotice extends StatefulWidget {
  final bool isChecked;
  final VoidCallback onToggleChecked;
  final VoidCallback onTermsTap;

  const HomeRoamingConfirmationTermsNotice({
    super.key,
    required this.isChecked,
    required this.onToggleChecked,
    required this.onTermsTap,
  });

  @override
  State<HomeRoamingConfirmationTermsNotice> createState() =>
      _HomeRoamingConfirmationTermsNoticeState();
}

class _HomeRoamingConfirmationTermsNoticeState
    extends State<HomeRoamingConfirmationTermsNotice> {
  late final TapGestureRecognizer _termsTapRecognizer;

  @override
  void initState() {
    super.initState();
    _termsTapRecognizer = TapGestureRecognizer()..onTap = widget.onTermsTap;
  }

  @override
  void didUpdateWidget(covariant HomeRoamingConfirmationTermsNotice oldWidget) {
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
            HomeRoamingConfirmationTheme.termsNoticeCheckboxRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: HomeRoamingConfirmationTheme.termsNoticeCheckboxTopOffset,
            ),
            child: Container(
              width: HomeRoamingConfirmationTheme.termsNoticeCheckboxSize,
              height: HomeRoamingConfirmationTheme.termsNoticeCheckboxSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.isChecked
                    ? HomeRoamingConfirmationTheme
                        .termsNoticeCheckboxCheckedFillColor
                    : Colors.transparent,
                border: Border.all(
                  width: 1,
                  color: HomeRoamingConfirmationTheme
                      .termsNoticeCheckboxBorderColor,
                ),
                borderRadius: BorderRadius.circular(
                  HomeRoamingConfirmationTheme.termsNoticeCheckboxRadius,
                ),
              ),
              child: widget.isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: HomeRoamingConfirmationTheme
                          .termsNoticeCheckboxIconSize,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(
          width: HomeRoamingConfirmationTheme.termsNoticeCheckboxToTextGap,
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HomeRoamingConfirmationTheme.termsNoticeTextWidth,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'By checking this box, I agree to the ',
                    style:
                        HomeRoamingConfirmationTheme.termsNoticeBodyTextStyle,
                  ),
                  TextSpan(
                    text: 'Terms & Conditions.',
                    style:
                        HomeRoamingConfirmationTheme.termsNoticeLinkTextStyle,
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
