import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
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
  bool _loadingFaceId = false;
  bool _loadingFingerprint = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FingerFaceSecurityCubit, FingerFaceSecurityState>(
      builder: (context, state) {
        final faceIdActive = state.faceIdEnabled;
        final fingerprintActive = state.fingerprintEnabled;

        return Column(
          children: [
            const _OrDividerRow(),
            const SizedBox(height: AuthModuleSizes.dividerToButtonsGap),
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    label: 'face id',
                    loading: _loadingFaceId,
                    active: faceIdActive,
                    onTap: () => _authenticate(context, isFace: true),
                  ),
                ),
                const SizedBox(width: AuthModuleSizes.socialButtonsGap),
                Expanded(
                  child: _SocialButton(
                    label: 'fingerprint',
                    loading: _loadingFingerprint,
                    active: fingerprintActive,
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
    if (_loadingFaceId || _loadingFingerprint) return;

    final cubit = context.read<FingerFaceSecurityCubit>();
    await cubit.authenticate(
      reason: isFace
          ? 'Use Face ID to sign in to MyAliv'
          : 'Use fingerprint to sign in to MyAliv',
      type: isFace ? BiometricTypeHint.face : BiometricTypeHint.fingerprint,
    );

    if (!context.mounted) return;
    if (cubit.state.status != FingerFaceSecurityStatus.authenticated) {
      final result = cubit.state.lastAuthResult;
      if (result == BiometricAuthResult.lockedOut) {
        AppToast.show(
          message:
              'Too many failed attempts. Please log in with your password.',
          type: ToastType.error,
        );
      } else if (result == BiometricAuthResult.failed) {
        AppToast.show(
          message: isFace
              ? 'Face not detected. Try again.'
              : 'Fingerprint not recognized. Please try again.',
          type: ToastType.error,
        );
      } else if (result == BiometricAuthResult.biometricsNotEnrolled ||
          result == BiometricAuthResult.biometricsNotAvailable) {
        // On most Android OEMs (Vivo, Samsung, Oppo, Xiaomi, OnePlus) face
        // unlock is implemented as a lock-screen-only feature and is not
        // exposed to third-party apps via BiometricPrompt. Guide the user to
        // the alternative instead of the generic "no biometrics" message.
        AppToast.show(
          message: isFace
              ? 'Face unlock is not available for apps on this device. Please use fingerprint instead.'
              : 'Fingerprint is not set up on this device. Please enroll a fingerprint in device settings.',
          type: ToastType.error,
        );
      }
      return;
    }

    // Fast path — if valid JWT tokens are still cached (session not
    // refresh-expired), skip the login API entirely. Avoids re-triggering
    // MFA/OTP for the common 20-min-idle case where tokens are still fresh.
    final existingSession = instance<AuthManager>().currentSession;
    if (existingSession != null && !existingSession.refreshExpired) {
      cubit.markSessionAuthenticated();
      await SessionTimeoutService().markActive();
      if (!context.mounted) return;
      context.go(AppRoutes.home);
      return;
    }

    // No valid session — fall back to replaying cached credentials.
    final creds = await CredentialStore().load();
    if (!context.mounted) return;

    if (creds == null) {
      AppToast.show(
        message: 'Please sign in with your password first.',
        type: ToastType.error,
      );
      return;
    }

    setState(() => isFace ? _loadingFaceId = true : _loadingFingerprint = true);
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
          AppToast.show(message: 'Welcome!', type: ToastType.success);
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
      AppToast.show(
        message: 'Sign-in failed. Please try again.',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(
          () => isFace ? _loadingFaceId = false : _loadingFingerprint = false,
        );
      }
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onTap,
    this.loading = false,
    this.active = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: Opacity(
        opacity: active ? 1.0 : 0.8,
        child: SizedBox(
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
