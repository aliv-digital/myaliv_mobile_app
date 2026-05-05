import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Shared add-ons proceed → confirmation navigation used by both
/// `HomePlanScreen` (add-ons tab) and the user-profile `PurchaseAddOnsScreen`.
class HomePlanAddOnsActions {
  const HomePlanAddOnsActions._();

  static void openConfirmation(BuildContext context, PlansState state) {
    final selected = state.addOns
        .where((addOn) => state.selectedAddOnIds.contains(addOn.id))
        .toList(growable: false);

    if (selected.isEmpty) {
      return;
    }

    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null) {
      AppToast.show(
        message: 'account information is unavailable, please try again',
        type: ToastType.error,
      );
      return;
    }

    final fullName = <String>[
      accountInfo.fName,
      accountInfo.lName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
    final phoneNumber = accountInfo.phoneNumber.isNotEmpty
        ? accountInfo.phoneNumber
        : accountInfo.primaryPhoneNumber;

    final activePlan = state.earliestAddOnsPrimaryPlan;

    final args = HomePlanConfirmationRouteArgs(
      phoneNumber: phoneNumber,
      accountHolderName: fullName,
      primaryPlanName: activePlan?.planName ?? '',
      primaryPlanPrice: 0,
      flow: HomePlanConfirmationEntryFlow.proceed,
      isPrimaryPlanActive: true,
      selectedAddOns: selected
          .map(
            (HomePlanAddOnModel addOn) => HomePlanConfirmationSelectedAddOn(
              id: addOn.id,
              title: addOn.title,
              price: addOn.price,
              vatAmount: addOn.vatAmount,
            ),
          )
          .toList(growable: false),
    );

    context.push(AppRoutes.homePlanConfirmationScreen, extra: args);
  }
}
