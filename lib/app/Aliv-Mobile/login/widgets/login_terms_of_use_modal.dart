import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../theme/login_theme.dart';

const String _demoTermsOfUseHtml = '''
  <h2>Welcome to MyAliv</h2>
  <p>
    Welcome to the MyAliv app. These Terms of Use explain the rules that apply
    when you access or use the app and its services.
  </p>
  <h2>Using the app</h2>
  <p>
    You may use the app for personal, lawful purposes. You are responsible for
    keeping your account details and password secure and for activity that
    occurs through your account.
  </p>
  <h2>Service availability</h2>
  <p>
    Features and services may be changed, suspended, or unavailable from time
    to time. We may also update these terms as the app and its services evolve.
  </p>
  <h2>Acceptable use</h2>
  <p>
    You must not misuse the app, attempt to gain unauthorized access, interfere
    with its operation, or use it in a way that violates applicable laws.
  </p>
  <h2>Demo notice</h2>
  <p>
    This is temporary sample content. The official Terms of Use will replace
    this text when the Terms of Use service becomes available.
  </p>
''';

Future<void> showLoginTermsOfUseModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (_) => const LoginTermsOfUseDialog(),
  );
}

class LoginTermsOfUseDialog extends StatelessWidget {
  const LoginTermsOfUseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dialogHeight = MediaQuery.sizeOf(context).height * 0.72;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: dialogHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 12, 14),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Terms of Use',
                          style: TextStyle(
                            color: AuthModuleColors.textBlack,
                            fontSize: 18,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: AuthModuleColors.lightGreyBorder,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Html(
                      data: _demoTermsOfUseHtml,
                      style: {
                        'body': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          color: const Color(0xFF707070),
                          fontFamily: 'CircularPro',
                          fontSize: FontSize(14),
                          fontWeight: FontWeight.w500,
                          lineHeight: const LineHeight(20 / 14),
                        ),
                        'h2': Style(
                          margin: Margins.only(bottom: 12, top: 20),
                          color: const Color(0xFF707070),
                          fontFamily: 'CircularPro',
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.w700,
                          lineHeight: const LineHeight(26 / 20),
                        ),
                        'p': Style(margin: Margins.only(bottom: 16)),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
