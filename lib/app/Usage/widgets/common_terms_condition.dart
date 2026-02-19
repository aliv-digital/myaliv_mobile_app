import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsAgreement extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;

  const TermsAgreement({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        /// Custom Checkbox
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: value
                    ? const Color(0xFF645D9C)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: value
                      ? const Color(0xFF645D9C)
                      : const Color(0xFFBDBDBD),
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
                  : null,
            ),
          ),
        ),

        const SizedBox(width: 10),

        /// Rich Text
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text:
                  'By checking this box, I agree to the ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                TextSpan(
                  text: 'Terms & Conditions.',
                  style: const TextStyle(
                    color: Color(0xFF645D9C),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    height: 1.43,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = onTermsTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
