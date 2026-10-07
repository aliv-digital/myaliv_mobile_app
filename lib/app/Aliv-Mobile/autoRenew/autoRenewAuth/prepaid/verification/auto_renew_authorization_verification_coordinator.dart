import '../repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verification_coordinator.dart';

typedef AutoRenewAuthorizationVerificationCoordinator =
    ActionVerificationCoordinator<AutoRenewPaymentMethodType>;
typedef OpenAutoRenewAuthorizationOtp =
    OpenActionOtp<AutoRenewPaymentMethodType>;
