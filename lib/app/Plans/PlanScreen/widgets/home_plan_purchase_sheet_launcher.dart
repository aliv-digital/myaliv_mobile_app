import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../core/utils/app_session.dart';
import '../../homeRoamingConfirmation/models/home_roaming_confirmation_models.dart';
import '../../mifiAltContact/model/mifi_alt_contact_route_args.dart';
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
  BasePlanModel? selectedApiPlan,
  int? selectedIndex,
}) {
  final plansState = context.read<PlansCubit>().state;
  final hasActivePlan = plansState.addOnsApiPrimaryPlans.isNotEmpty;
  final activePlanEndDate = plansState.earliestAddOnsPrimaryPlan?.endDateTime;
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
                forceNow: false,
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
                forceNow: true,
              ),
            );
          },
        );
      }

      if (hasActivePlan) {
        final endDateText = activePlanEndDate != null
            ? DateFormat('dd MMM yyyy').format(activePlanEndDate)
            : 'the end of your current plan';
        return HomePlanWalletPaymentActivateOrFutureBottomSheet(
          warningText:
              'activating now replaces the account owner current plan, '
              'you can activate the account owner plan as a future plan and '
              'it will start when their current plan ends on $endDateText.',
          planName: plan.title,
          planDurationText: plan.subtitle,
          planPriceText: _priceText(plan.price),
          onBackPressed: () => Navigator.of(sheetContext).pop(),
          onActivateNowPressed: () {
            Navigator.of(sheetContext).pop();
            if (selectedTab == HomePlanTab.mifi) {
              _pushMifiAltContact(
                context: context,
                selectedApiPlan: selectedApiPlan,
                fallbackPlan: plan,
                forceNow: true,
              );
              return;
            }
            if (selectedTab == HomePlanTab.libertyGlobal) {
              context.push(
                AppRoutes.homePlanConfirmationScreen,
                extra: _futurePlanConfirmationRouteArgs(
                  selectedApiPlan: selectedApiPlan,
                  fallbackPlan: plan,
                  forceNow: true,
                ),
              );
              return;
            }
            context.push(
              AppRoutes.homePurchasePlanAddOns,
              extra: selectedPlanExtra,
            );
          },
          onFuturePlanPressed: () {
            Navigator.of(sheetContext).pop();
            if (selectedTab == HomePlanTab.mifi) {
              _pushMifiAltContact(
                context: context,
                selectedApiPlan: selectedApiPlan,
                fallbackPlan: plan,
                forceNow: false,
              );
              return;
            }
            context.push(
              AppRoutes.homePlanConfirmationScreen,
              extra: _futurePlanConfirmationRouteArgs(
                selectedApiPlan: selectedApiPlan,
                fallbackPlan: plan,
                forceNow: false,
              ),
            );
          },
        );
      }

      return HomePlanWalletPaymentActivateBottomSheet(
        warningText:
            'you have no current plans, so your new plan will start immediately.',
        planName: plan.title,
        planDurationText: plan.subtitle,
        planPriceText: _priceText(plan.price),
        onBackPressed: () => Navigator.of(sheetContext).pop(),
        onActivateNowPressed: () {
          AppSession.appRoute = 'prepaidPlan';
          Navigator.of(sheetContext).pop();
          if (selectedTab == HomePlanTab.mifi) {
            _pushMifiAltContact(
              context: context,
              selectedApiPlan: selectedApiPlan,
              fallbackPlan: plan,
              forceNow: true,
            );
            return;
          }
          if (selectedTab == HomePlanTab.libertyGlobal) {
            context.push(
              AppRoutes.homePlanConfirmationScreen,
              extra: _futurePlanConfirmationRouteArgs(
                selectedApiPlan: selectedApiPlan,
                fallbackPlan: plan,
                forceNow: true,
              ),
            );
            return;
          }
          context.push(
            AppRoutes.homePurchasePlanAddOns,
            extra: selectedPlanExtra,
          );
        },
      );
    },
  );
}

void _pushMifiAltContact({
  required BuildContext context,
  required BasePlanModel? selectedApiPlan,
  required HomePlanModel fallbackPlan,
  required bool forceNow,
}) {
  final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
  final prefilledAltNumber = accountInfo?.altPhoneNumber.trim() ?? '';

  context.push(
    AppRoutes.homePlanMifiAltContact,
    extra: MifiAltContactRouteArgs(
      selectedApiPlan: selectedApiPlan,
      fallbackPlan: fallbackPlan,
      forceNow: forceNow,
      prefilledAltNumber: prefilledAltNumber,
    ),
  );
}

HomeRoamingConfirmationRouteArgs _roamingConfirmationRouteArgs({
  required BasePlanModel? selectedApiPlan,
  required bool showDateField,
  required DateTime beginDate,
  required bool forceNow,
}) {
  return HomeRoamingConfirmationRouteArgs(
    // Keep the current phone fallback. The important dynamic data for this
    // flow is the selected roaming/roameasy plan and its chosen start date.
    phoneNumber: '242-801-1616',
    selectedPlan: selectedApiPlan,
    beginDate: beginDate,
    showDateField: showDateField,
    forceNow: forceNow,
  );
}

PlanPurchasePlanAddOnsRouteArgs _selectedPlanRouteExtra({
  required BasePlanModel? selectedApiPlan,
  required int? selectedIndex,
}) {
  return PlanPurchasePlanAddOnsRouteArgs(
    selectedApiPlan: selectedApiPlan,
    selectedIndex: selectedIndex,
    forceNow: true,
  );
}

String _priceText(double price) => '\$ ${price.toStringAsFixed(2)}';

HomePlanConfirmationRouteArgs _futurePlanConfirmationRouteArgs({
  required BasePlanModel? selectedApiPlan,
  required HomePlanModel fallbackPlan,
  required bool forceNow,
}) {
  final accountState = instance<AccountInfoCubit>().state;

  return HomePlanConfirmationRouteArgs(
    phoneNumber: _accountUsername(accountState),
    accountHolderName: _accountDisplayName(accountState),
    primaryPlanId: selectedApiPlan?.planId.trim() ?? fallbackPlan.id,
    primaryPlanName: _primaryPlanName(
      selectedApiPlan: selectedApiPlan,
      fallbackPlan: fallbackPlan,
    ),
    primaryPlanTypeCode: selectedApiPlan?.planType.trim() ?? 'P',
    primaryPlanPrice: selectedApiPlan?.planAmount ?? fallbackPlan.price,
    primaryPlanVatAmount: selectedApiPlan?.vatAmount ?? 0,
    futurePlanStartDate: selectedApiPlan?.startDate.trim() ?? '',
    flow: HomePlanConfirmationEntryFlow.skip,
    forceNow: forceNow,
  );
}

String _accountDisplayName(AccountInfoState accountState) {
  final fullName = accountState.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  return _nameFromEmail(accountState.email);
}

String _accountUsername(AccountInfoState accountState) {
  final accountInfo = accountState.accountInfo;
  final username = accountInfo?.username.trim() ?? '';
  if (username.isNotEmpty) return username;

  final primaryPhoneNumber = accountInfo?.primaryPhoneNumber.trim() ?? '';
  if (primaryPhoneNumber.isNotEmpty) return primaryPhoneNumber;

  final phoneNumber = accountInfo?.phoneNumber.trim() ?? '';
  return phoneNumber.isEmpty ? '--' : phoneNumber;
}

String _primaryPlanName({
  required BasePlanModel? selectedApiPlan,
  required HomePlanModel fallbackPlan,
}) {
  final selectedPlanName = selectedApiPlan?.planName.trim();
  if (selectedPlanName != null && selectedPlanName.isNotEmpty) {
    return selectedPlanName;
  }

  return fallbackPlan.title;
}

String _nameFromEmail(String? email) {
  final normalizedEmail = email?.trim() ?? '';
  if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
    return 'User';
  }

  return normalizedEmail.split('@').first;
}
