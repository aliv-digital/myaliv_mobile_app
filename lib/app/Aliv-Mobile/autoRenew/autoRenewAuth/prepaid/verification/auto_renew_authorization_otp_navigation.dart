import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../repository/auto_renew_auth_prepaid_repository.dart';
import 'auto_renew_authorization_submission.dart';
import 'auto_renew_authorization_verification_coordinator.dart';

/// Runs the authorization OTP step from the Setup screen, then pushes the
/// Authorization form with the one-use [AutoRenewAuthorizationVerifiedResult].
///
/// Returns the pushed route's pop value (whatever the Auth screen returns),
/// or `null` if OTP was cancelled, failed, or the owner route is no longer
/// current.
Future<Object?> navigateToAutoRenewAuthWithOtp(
  BuildContext context, {
  required AutoRenewPaymentMethodType paymentMethod,
  String? cardToken,
  String? cardLastDigits,
  AutoRenewAuthorizationVerificationCoordinator? coordinator,
}) async {
  final ownerRoute = ModalRoute.of(context);
  if (!context.mounted || ownerRoute?.isCurrent != true) {
    return null;
  }

  final coord = coordinator ?? AutoRenewAuthorizationVerificationCoordinator();
  final attemptId = Object();

  AutoRenewAuthorizationVerifiedResult? verified;
  try {
    verified = await coord.verify(
      paymentMethod: paymentMethod,
      attemptId: attemptId,
      isOwnerActive: () => context.mounted && ownerRoute?.isActive == true,
      openOtp: (args) {
        if (!context.mounted || ownerRoute?.isCurrent != true) {
          return Future.value(null);
        }
        return context.push<AutoRenewAuthorizationVerifiedResult>(
          AppRoutes.autoRenewAuthorizationOtp,
          extra: args,
        );
      },
    );
  } on CallLogsVerificationException catch (error) {
    if (context.mounted) {
      AppToast.show(message: error.message, type: ToastType.error);
    }
    return null;
  } catch (_) {
    if (context.mounted) {
      AppToast.show(
        message: 'Verification failed. Please try again.',
        type: ToastType.error,
      );
    }
    return null;
  }

  if (!context.mounted ||
      ownerRoute?.isCurrent != true ||
      verified == null ||
      !verified.isValid) {
    return null;
  }

  return context.push<Object>(
    AppRoutes.autoRenewAuthPrepaidScreen,
    extra: AutoRenewAuthArgs(
      paymentMethod: paymentMethod,
      cardToken: cardToken,
      cardLastDigits: cardLastDigits,
      verifiedResult: verified,
    ),
  );
}
