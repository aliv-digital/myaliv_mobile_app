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
        // SizedBox(
        //   width: 20,
        //   height: 20,
        //   child: Checkbox(
        //     value: value,
        //     onChanged: (v) => onChanged(v ?? false),
        //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     visualDensity: VisualDensity.compact,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(4),
        //     ),
        //     side: BorderSide(
        //       color: RevConfirmationPrepaidTheme.checkboxBorder,
        //       width: 1.2,
        //     ),
        //     activeColor: RevConfirmationPrepaidTheme.checkboxActive,
        //   ),
        // ),
        // const SizedBox(width: 10),
        Expanded(
          child: Padding(
            // checkbox height এর সাথে text baseline align করার জন্য
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 332,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'By pressing “continue” you agree to the ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                    TextSpan(
                      text: 'Terms & Conditions.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
        ),
      ],
    );
  }
}
