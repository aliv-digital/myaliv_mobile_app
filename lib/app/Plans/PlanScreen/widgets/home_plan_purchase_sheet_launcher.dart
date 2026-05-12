import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../core/utils/app_session.dart';
import '../../../Home/home/data/home_ui_config.dart';
import '../../homeRoamingConfirmation/models/home_roaming_confirmation_models.dart';
import '../../purchasePlanAddOns/model/plan_purchase_plan_add_ons_route_args.dart';
import '../models/base_plan_model.dart';
import '../models/plan_model.dart';
import '../repository/plan_types.dart';
import 'roam_bottom_sheet.dart';
import 'wallet_payment_activate_bottom_sheet.dart';
import 'wallet_payment_activate_or_future_bottom_sheet.dart';

Future<void> showHomePlanPurchaseBottomSheet({
  required BuildContext context,
  required HomePlanModel plan,
  required HomePlanTab selectedTab,
  required HomeUiConfig homeUiConfig,
  BasePlanModel? selectedApiPlan,
  int? selectedIndex,
}) {
  final hasActivePlan = homeUiConfig.hasActivePlan;
  final selectedPlanExtra = _selectedPlanRouteExtra(
    selectedApiPlan: selectedApiPlan,
    selectedIndex: selectedIndex,
  );

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    isScrollControlled: true,
    builder: (sheetContext) {
      if (selectedTab == HomePlanTab.roaming ||
          selectedTab == HomePlanTab.roameasy) {
        if (kDebugMode) {
          debugPrint("--------- selected tab is roaming or roameasy ---------");
        }
        return HomePlanRoamBottomSheet(
          onBackPressed: () => Navigator.of(sheetContext).pop(),
          onDateApplied: (pickedDate) {
            Navigator.of(sheetContext).pop();
            context.push(
              AppRoutes.homeRoamingConfirmation,
              extra: _roamingConfirmationRouteArgs(
                selectedApiPlan: selectedApiPlan,
                showDateField: true,
                beginDate: pickedDate,
              ),
            );
          },
          onActivateNowPressed: () {
            Navigator.of(sheetContext).pop();
            context.push(
              AppRoutes.homeRoamingConfirmation,
              extra: _roamingConfirmationRouteArgs(
                selectedApiPlan: selectedApiPlan,
                showDateField: false,
                beginDate: DateTime.now(),
              ),
            );
          },
        );
      }

      if (hasActivePlan) {
        //&& selectedTab == HomePlanTab.addOns
        return HomePlanWalletPaymentActivateOrFutureBottomSheet(
          warningText:
              'activating now replaces the account owner current plan, '
              'you can activate the account owner plan as a future plan and '
              'it will start when their current plan ends on XXX.',
          planName: plan.title,
          planDurationText: plan.subtitle,
          planPriceText: _priceText(plan.price),
          onBackPressed: () => Navigator.of(sheetContext).pop(),
          onActivateNowPressed: () {
            Navigator.of(sheetContext).pop();
            context.push(
              AppRoutes.homePurchasePlanAddOns,
              extra: selectedPlanExtra,
            );
          },
          onFuturePlanPressed: () {
            Navigator.of(sheetContext).pop();
            context.push(
              AppRoutes.homePurchasePlanAddOns,
              extra: selectedPlanExtra,
            );
          },
        );
      }

      // we will go to next screen to show  "AvailableBoltOns"
      // will work here
      return HomePlanWalletPaymentActivateBottomSheet(
        warningText: 'the account owner has no current plan, so their new plan will start immediately.',
        planName: plan.title,
        planDurationText: plan.subtitle,
        planPriceText: _priceText(plan.price),
        onBackPressed: () => Navigator.of(sheetContext).pop(),
        onActivateNowPressed: () {
          AppSession.appRoute = 'prepaidPlan';
          Navigator.of(sheetContext).pop();
          context.push(
            AppRoutes.homePurchasePlanAddOns,
            extra: selectedPlanExtra,
          );
        },
      );
    },
  );
}

HomeRoamingConfirmationRouteArgs _roamingConfirmationRouteArgs({
  required BasePlanModel? selectedApiPlan,
  required bool showDateField,
  required DateTime beginDate,
}) {
  return HomeRoamingConfirmationRouteArgs(
    // Keep the current phone fallback. The important dynamic data for this
    // flow is the selected roaming/roameasy plan and its chosen start date.
    phoneNumber: '242-801-1616',
    selectedPlan: selectedApiPlan,
    beginDate: beginDate,
    showDateField: showDateField,
  );
}

PlanPurchasePlanAddOnsRouteArgs? _selectedPlanRouteExtra({
  required BasePlanModel? selectedApiPlan,
  required int? selectedIndex,
}) {
  if (selectedApiPlan == null) {
    return null;
  }

  return PlanPurchasePlanAddOnsRouteArgs(
    selectedApiPlan: selectedApiPlan,
    selectedIndex: selectedIndex,
  );
}

String _priceText(double price) => '\$ ${price.toStringAsFixed(2)}';
