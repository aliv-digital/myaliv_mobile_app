import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/auth/hard_logout.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../createPassword/view/create_password_page.dart';
import '../model/password_recovery_create_password_args.dart';
import '../widgets/save_password_bottom_sheet.dart';

/// Owns recovery cancellation without changing the shared password form.
class PasswordRecoveryCreatePasswordScreen extends StatefulWidget {
  const PasswordRecoveryCreatePasswordScreen({super.key});

  @override
  State<PasswordRecoveryCreatePasswordScreen> createState() =>
      _PasswordRecoveryCreatePasswordScreenState();
}

class _PasswordRecoveryCreatePasswordScreenState
    extends State<PasswordRecoveryCreatePasswordScreen> {
  bool _backStarted = false;
  PasswordRecoveryCreatePasswordArgs? _args;

  @override
  void initState() {
    super.initState();
    // Hand-off from the OTP screen. Latched locally so a subsequent
    // GoRouter rebuild (e.g. router.refresh()) still sees the args even
    // after the module holder is cleared.
    _args = PasswordRecoveryContext.pending;
    PasswordRecoveryContext.pending = null;
  }

  Future<void> _onBack() async {
    if (_backStarted || !mounted) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return;
    }
    // Keep this latched while exiting, including across rebuilds and repeats.
    _backStarted = true;
    final router = GoRouter.of(context);
    await performHardLogout(navigate: false);
    if (!mounted || !route.isCurrent) {
      return;
    }

    // Recovery routes are top-level. Pop only the expected phone-entry parent;
    // a direct/alternate entry must not expose an unrelated or completed route.
    final matches = router.routerDelegate.currentConfiguration.matches;
    final parent = matches.length > 1
        ? matches[matches.length - 2].route
        : null;
    if (parent is GoRoute && parent.path == AppRoutes.forgetPassword) {
      router.pop();
    } else {
      router.go(AppRoutes.forgetPassword);
    }
  }

  Future<void> _onSuccess(BuildContext context, String newPassword) async {
    final args = _args;
    if (instance.isRegistered<AnalyticsService>()) {
      await instance<AnalyticsService>().logPasswordResetCompleted();
    }
    if (!context.mounted) return;
    context.go(AppRoutes.home);
    if (args == null) return;
    // Defer the sheet until home has mounted, then present it via the root
    // navigator so it overlays home rather than the (already-replaced)
    // create-password route.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext == null) return;
      SavePasswordBottomSheet.show(rootContext).then((shouldSave) async {
        if (!shouldSave) return;
        final store = CredentialStore();
        await store.save(
          apiPhone: args.apiPhoneNumber,
          password: newPassword,
          displayPhone: args.phoneNumber,
        );
        await store.saveSaveMyPasswordPref(true);
      });
    });
  }

  @override
  Widget build(BuildContext context) =>
      CreatePasswordScreen(onBack: _onBack, onSuccess: _onSuccess);
}
