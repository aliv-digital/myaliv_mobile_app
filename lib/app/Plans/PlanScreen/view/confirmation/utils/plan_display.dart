import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/active_device.dart';
import 'package:myaliv_mobile_app/core/utils/user_display_name.dart';

import 'confirmation_formatters.dart';

String planTitleFor(HomePlansPostPaidPlanModel? plan) {
  if (plan == null) return 'travel20 - 7 days';
  final name = plan.planName.trim();
  final title = name.isEmpty ? 'selected plan' : name;
  final duration = plan.durationText.trim();
  if (duration.isEmpty || duration == '--') return title;
  return '$title - $duration';
}

String planPriceFor(HomePlansPostPaidPlanModel? plan) {
  if (plan == null) return '\$ --.--';
  return formatConfirmationCurrency(plan.planAmount);
}

String planTypeLabelFor(HomePlansPostPaidPlanModel? plan) {
  switch (plan?.planType.trim().toUpperCase()) {
    case 'A':
      return 'standalone';
    case 'S':
      return 'secondary';
    case 'P':
      return 'primary';
    default:
      return 'plan';
  }
}

String accountDisplayName(AccountInfoState state) =>
    resolveActiveDeviceDisplayName(account: state);

String accountPhoneNumber(AccountInfoState state) {
  final activeTn = ActiveDevice.tn();
  if (activeTn != null && activeTn.isNotEmpty) {
    return formatConfirmationPhone(activeTn);
  }

  final accountInfo = state.accountInfo;
  final primaryPhoneNumber = accountInfo?.primaryPhoneNumber.trim() ?? '';
  if (primaryPhoneNumber.isNotEmpty) {
    return formatConfirmationPhone(primaryPhoneNumber);
  }

  final phoneNumber = accountInfo?.phoneNumber.trim() ?? '';
  return phoneNumber.isEmpty ? '--' : formatConfirmationPhone(phoneNumber);
}
