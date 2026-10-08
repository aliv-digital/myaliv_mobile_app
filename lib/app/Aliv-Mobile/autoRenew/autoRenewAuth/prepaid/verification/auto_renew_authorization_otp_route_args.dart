import '../repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_route_args.dart';

typedef AutoRenewAuthorizationVerificationAttempt =
    ActionVerificationAttempt<AutoRenewPaymentMethodType>;
typedef AutoRenewAuthorizationOtpRouteArgs =
    ActionOtpRouteArgs<AutoRenewPaymentMethodType>;
