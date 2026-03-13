import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../core/utils/app_session.dart';
import '../models/plan_model.dart';
import '../repository/home_plan_repository.dart';
import 'roam_bottom_sheet.dart';
import 'wallet_payment_activate_bottom_sheet.dart';
import 'wallet_payment_activate_or_future_bottom_sheet.dart';

void showHomePlanPurchaseBottomSheet({
  required BuildContext context,
  required HomePlanModel plan,
  required HomePlanTab selectedTab,
}) {
  final hasActivePlan = _hasActivePlan(plan);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    isScrollControlled: true,
    builder: (sheetContext) {
      if (selectedTab == HomePlanTab.roaming ||
          selectedTab == HomePlanTab.roameasy) {
        return HomePlanRoamBottomSheet(
          onBackPressed: () => Navigator.of(sheetContext).pop(),
          onDateApplied: (_) {
            Navigator.of(sheetContext).pop();
            context.push(
              AppRoutes.homeRoamingConfirmation,
              extra: {'showDateField': true},
            );
          },
          onActivateNowPressed: () {
            Navigator.of(sheetContext).pop();
            context.push(
              AppRoutes.homeRoamingConfirmation,
              extra: {'showDateField': false},
            );
          },
        );
      }

      if (hasActivePlan && selectedTab == HomePlanTab.addOns) {
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
            context.push(AppRoutes.homePurchasePlanAddOns);
          },
          onFuturePlanPressed: () {
            Navigator.of(sheetContext).pop();
            context.push(AppRoutes.homePurchasePlanAddOns);
          },
        );
      }

      return HomePlanWalletPaymentActivateBottomSheet(
        warningText:
            'the account owner has no current plan, so their new plan will start immediately.',
        planName: plan.title,
        planDurationText: plan.subtitle,
        planPriceText: _priceText(plan.price),
        onBackPressed: () => Navigator.of(sheetContext).pop(),
        onActivateNowPressed: () {
          AppSession.appRoute = 'prepaidPlan';
          Navigator.of(sheetContext).pop();
          context.push(AppRoutes.homePurchasePlanAddOns);
        },
      );
    },
  );
}

bool _hasActivePlan(HomePlanModel plan) {
  final subtitle = plan.subtitle.toLowerCase();
  return !subtitle.contains('begins immediately') &&
      !subtitle.contains('start immediately');
}

String _priceText(double price) => '\$ ${price.toStringAsFixed(2)}';
