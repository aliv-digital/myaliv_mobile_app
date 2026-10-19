import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'action_verification_coordinator.dart';
import 'action_verified_result.dart';

/// Navigation only. Sensitive form values and business submissions stay local.
Future<ActionVerifiedResult<ProtectedAccountAction>?> requestAccountActionOtp({
  required BuildContext context,
  required ActionVerificationCoordinator<ProtectedAccountAction> coordinator,
  required ProtectedAccountAction purpose,
  required Object attemptId,
  bool Function()? isOwnerActive,
}) async {
  final ownerRoute = ModalRoute.of(context);
  if (!context.mounted || ownerRoute?.isCurrent != true) {
    return null;
  }
  final result = await coordinator.verifyAction(
    purpose: purpose,
    attemptId: attemptId,
    isOwnerActive: () =>
        context.mounted &&
        ownerRoute?.isActive == true &&
        (isOwnerActive?.call() ?? true),
    openOtp: (args) {
      if (!context.mounted || ownerRoute?.isCurrent != true) {
        return Future.value(null);
      }
      return context.push<ActionVerifiedResult<ProtectedAccountAction>>(
        AppRoutes.accountActionOtp,
        extra: args,
      );
    },
  );
  if (!context.mounted || ownerRoute?.isCurrent != true) {
    return null;
  }
  return result;
}
