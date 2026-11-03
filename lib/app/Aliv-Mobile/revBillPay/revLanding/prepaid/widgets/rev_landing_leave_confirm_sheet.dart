import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

import '../theme/rev_landing_prepaid_theme.dart';

/// Confirms before handing off to REV. Cancel and dismissal open nothing.
class RevLandingLeaveConfirmSheet extends StatelessWidget {
  const RevLandingLeaveConfirmSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const RevLandingLeaveConfirmSheet(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: RevLandingPrepaidTheme.buttonBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "you're leaving myALIV to pay on rev.bs",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RevLandingPrepaidTheme.buttonText,
                  fontSize: 16,
                  fontFamily: RevLandingPrepaidTheme.fontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              DefaultButton(
                label: 'continue',
                isLoading: false,
                height: 50,
                fontSize: 15,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 12),
              DefaultButton(
                label: 'cancel',
                isLoading: false,
                height: 50,
                fontSize: 15,
                backgroundColor: Colors.white,
                textColor: ColorManager.primaryPurple,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
