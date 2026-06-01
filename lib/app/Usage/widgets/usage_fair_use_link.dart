import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Right-aligned "fair use policy" link sitting between the active plan
/// card and the bucket usage list. Same launch + toast fallback as
/// `BucketDetailModal._openFairUsePolicy` and the plan add-ons screen,
/// so users see one consistent fair-use experience across the app.
class UsageFairUseLink extends StatelessWidget {
  const UsageFairUseLink({super.key});

  static final Uri _uri =
      Uri.parse('https://www.bealiv.com/fair-use-policy/');

  Future<void> _launch() async {
    try {
      final launched = await launchUrl(
        _uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // launchUrl can throw PlatformException when no handler is
      // installed for the URI scheme — fall through to the toast.
    }
    AppToast.show(
      message: 'could not open fair use policy',
      type: ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _launch,
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
