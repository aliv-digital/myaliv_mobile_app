import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/fair_use_policy_modal.dart';

/// Right-aligned "fair use policy" link sitting between the active plan
/// card and the bucket usage list. Shows the Fair Use Policy modal,
/// so users see one consistent fair-use experience across the app.
class UsageFairUseLink extends StatelessWidget {
  const UsageFairUseLink({super.key});

  Future<void> _launch(BuildContext context) async {
    await showFairUsePolicyModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => _launch(context),
          child: const Text(
            'fair use policy',
            style: TextStyle(
              color: Color(0xFF645D9C),
              fontSize: 13,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF645D9C),
            ),
          ),
        ),
      ),
    );
  }
}
