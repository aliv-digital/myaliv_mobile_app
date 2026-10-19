import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/auth/hard_logout.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../createPassword/view/create_password_page.dart';

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

  @override
  Widget build(BuildContext context) => CreatePasswordScreen(onBack: _onBack);
}
