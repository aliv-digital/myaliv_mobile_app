import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../settings/privacy/repository/privacy_repository.dart';
import '../../settings/privacy/repository/privacy_repository_impl.dart';
import '../theme/login_theme.dart';

Future<void> showLoginPrivacyPolicyModal(
  BuildContext context, {
  PrivacyRepository? repository,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (_) => LoginPrivacyPolicyDialog(
      repository: repository ?? PrivacyRepositoryImpl(),
    ),
  );
}

class LoginPrivacyPolicyDialog extends StatefulWidget {
  const LoginPrivacyPolicyDialog({super.key, required this.repository});

  final PrivacyRepository repository;

  @override
  State<LoginPrivacyPolicyDialog> createState() =>
      _LoginPrivacyPolicyDialogState();
}

class _LoginPrivacyPolicyDialogState extends State<LoginPrivacyPolicyDialog> {
  late Future<PrivacyContent> _privacyContent;

  @override
  void initState() {
    super.initState();
    _privacyContent = widget.repository.fetchContent();
  }

  void _retry() {
    setState(() {
      _privacyContent = widget.repository.fetchContent();
    });
  }

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
                          'Privacy Policy',
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
                    height: 1, color: AuthModuleColors.lightGreyBorder),
                Expanded(
                  child: FutureBuilder<PrivacyContent>(
                    future: _privacyContent,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AuthModuleColors.alivPurple,
                          ),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return _PrivacyPolicyError(onRetry: _retry);
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: Html(
                          data: snapshot.data!.htmlContent,
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
                          },
                        ),
                      );
                    },
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

class _PrivacyPolicyError extends StatelessWidget {
  const _PrivacyPolicyError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Unable to load the privacy policy. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'retry',
                style: TextStyle(
                  color: AuthModuleColors.alivPurple,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
