import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/model/mifi_alt_contact_route_args.dart';

class MifiAltContactArgsBuilder {
  const MifiAltContactArgsBuilder._();

  static HomePlanConfirmationRouteArgs buildConfirmationArgs({
    required MifiAltContactRouteArgs routeArgs,
    required AccountInfoState accountState,
    required String altContactNumber,
    required bool marketingOptIn,
  }) {
    final selectedApiPlan = routeArgs.selectedApiPlan;
    final fallbackPlan = routeArgs.fallbackPlan;

    return HomePlanConfirmationRouteArgs(
      phoneNumber: _accountUsername(accountState),
      accountHolderName: _accountDisplayName(accountState),
      primaryPlanId: selectedApiPlan?.planId.trim() ?? fallbackPlan.id,
      primaryPlanName: _planName(
        selectedApiPlan: selectedApiPlan,
        fallbackPlan: fallbackPlan,
      ),
      primaryPlanTypeCode: selectedApiPlan?.planType.trim() ?? 'P',
      primaryPlanPrice: selectedApiPlan?.planAmount ?? fallbackPlan.price,
      primaryPlanVatAmount: selectedApiPlan?.vatAmount ?? 0,
      futurePlanStartDate: selectedApiPlan?.startDate.trim() ?? '',
      flow: HomePlanConfirmationEntryFlow.skip,
      forceNow: routeArgs.forceNow,
      altContactNumber: altContactNumber,
      marketingOptIn: marketingOptIn,
    );
  }

  static String _accountDisplayName(AccountInfoState accountState) {
    final fullName = accountState.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return _nameFromEmail(accountState.email);
  }

  static String _accountUsername(AccountInfoState accountState) {
    final accountInfo = accountState.accountInfo;
    final username = accountInfo?.username.trim() ?? '';
    if (username.isNotEmpty) return username;
    final primaryPhone = accountInfo?.primaryPhoneNumber.trim() ?? '';
    if (primaryPhone.isNotEmpty) return primaryPhone;
    final phone = accountInfo?.phoneNumber.trim() ?? '';
    return phone.isEmpty ? '--' : phone;
  }

  static String _planName({
    required BasePlanModel? selectedApiPlan,
    required HomePlanModel fallbackPlan,
  }) {
    final name = selectedApiPlan?.planName.trim();
    if (name != null && name.isNotEmpty) return name;
    return fallbackPlan.title;
  }

  static String _nameFromEmail(String? email) {
    final normalized = email?.trim() ?? '';
    if (normalized.isEmpty || !normalized.contains('@')) return 'User';
    return normalized.split('@').first;
  }
}
