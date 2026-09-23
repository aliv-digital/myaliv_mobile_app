import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../loginOtp/model/login_otp_route_args.dart';
import '../model/auth_response_model.dart';
import '../repository/auth_repository.dart';
import '../services/auth_completion_service.dart';
import '../theme/login_theme.dart';

class LoginSocialButtons extends StatefulWidget {
  const LoginSocialButtons({super.key});

  @override
  State<LoginSocialButtons> createState() => _LoginSocialButtonsState();
}

class _LoginSocialButtonsState extends State<LoginSocialButtons> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FingerFaceSecurityCubit, FingerFaceSecurityState>(
      builder: (context, state) {
        final showFingerprint = state.fingerprintEnabled;
        final showFaceId = state.faceIdEnabled;

        if (!showFingerprint && !showFaceId) return const SizedBox.shrink();

        return Column(
          children: [
            const _OrDividerRow(),
            const SizedBox(height: AuthModuleSizes.dividerToButtonsGap),
            Row(
              children: [
                if (showFaceId) ...[
                  Expanded(
                    child: _SocialButton(
                      label: 'face id',
                      loading: _loading,
                      onTap: () => _authenticate(context, isFace: true),
                    ),
                  ),
                  if (showFingerprint)
                    const SizedBox(width: AuthModuleSizes.socialButtonsGap),
                ],
                if (showFingerprint)
                  Expanded(
                    child: _SocialButton(
                      label: 'fingerprint',
                      loading: _loading,
                      onTap: () => _authenticate(context, isFace: false),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _authenticate(
    BuildContext context, {
    required bool isFace,
  }) async {
    if (_loading) return;

    final cubit = context.read<FingerFaceSecurityCubit>();
    await cubit.authenticate(
      reason: isFace
          ? 'Use Face ID to sign in to MyAliv'
          : 'Use fingerprint to sign in to MyAliv',
    );

    if (!context.mounted) return;
    if (cubit.state.status != FingerFaceSecurityStatus.authenticated) return;

    // Biometric passed — now replay cached credentials against the API.
    final creds = await CredentialStore().load();
    if (!context.mounted) return;

    if (creds == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please sign in with your password first.'),
          ),
        );
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await LoginRepository().login(
        username: creds.apiPhone,
        password: creds.password,
      );

      if (!context.mounted) return;

      switch (result) {
        case LoginSuccess(:final session):
          await const AuthCompletionService().complete(
            session: session,
            appUiConfigCubit: context.read<AppUiConfigCubit>(),
          );
          if (!context.mounted) return;
          cubit.markSessionAuthenticated();
          context.go(AppRoutes.home);

        case LoginMfaChallenge(:final mfaToken):
          // API still requires OTP — forward to OTP screen.
          context.push(
            AppRoutes.loginOtp,
            extra: LoginOtpRouteArgs(
              mfaToken: mfaToken,
              phoneNumber: creds.apiPhone,
              apiPhoneNumber: creds.apiPhone,
            ),
          );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Sign-in failed. Please try again.')),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthModuleSizes.socialButtonHeight,
      child: OutlinedButton(
        style: AuthModuleButtonStyles.socialOutlined,
        onPressed: loading ? null : onTap,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: AuthModuleTextStyles.socialMediaButton,
              ),
      ),
    );
  }
}

class _OrDividerRow extends StatelessWidget {
  const _OrDividerRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ShortDivider(),
        const SizedBox(width: AuthModuleSizes.dividerLabelGap),
        const Text(
          'or sign in with',
          textAlign: TextAlign.center,
          style: AuthModuleTextStyles.orSignInWith,
        ),
        const SizedBox(width: AuthModuleSizes.dividerLabelGap),
        _ShortDivider(),
      ],
    );
  }
}

class _ShortDivider extends StatelessWidget {
  const _ShortDivider();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AuthModuleColors.lightGreyBorder,
      child: SizedBox(
        width: AuthModuleSizes.dividerWidth,
        height: AuthModuleSizes.dividerHeight,
      ),
    );
  }
}
