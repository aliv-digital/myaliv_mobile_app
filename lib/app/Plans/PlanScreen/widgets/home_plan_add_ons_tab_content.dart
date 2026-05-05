import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/auto_renew_actions.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/model/plan_purchase_add_on_models.dart'
    as plan_add_ons_models;
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_add_on_tile.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_fair_use_policy_card.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_plan_red_image_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/plans_state.dart';
import '../models/add_on_model.dart';
import '../models/base_plan_model.dart';
import '../repository/plan_types.dart';

class HomePlanAddOnsTabContent extends StatelessWidget {
  const HomePlanAddOnsTabContent({
    super.key,
    required this.activePrimaryPlan,
    required this.addOns,
    required this.selectedAddOnIds,
    required this.onToggleAddOn,
  });

  static const double _addOnsTabHorizontalPadding = 25;
  static final Uri _fairUsePolicyUri =
      Uri.parse('https://www.bealiv.com/fair-use-policy/');

  Future<void> _openFairUsePolicy() async {
    try {
      final launched = await launchUrl(
        _fairUsePolicyUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // Fall through to the toast — `launchUrl` can throw a PlatformException
      // when no handler is installed for the URI scheme.
    }
    AppToast.show(
      message: 'could not open fair use policy',
      type: ToastType.error,
    );
  }

  final BasePlanModel? activePrimaryPlan;
  final List<HomePlanAddOnModel> addOns;
  final Set<String> selectedAddOnIds;
  final ValueChanged<HomePlanAddOnModel> onToggleAddOn;

  plan_add_ons_models.PlanPurchaseActivePlanSummary _buildActivePlanSummary() {
    return plan_add_ons_models.PlanPurchaseActivePlanSummary(
      label: 'active plan',
      name: activePrimaryPlan?.planName.trim().isNotEmpty == true
          ? activePrimaryPlan!.planName
          : '--',
      autoRenew: activePrimaryPlan?.autoRenew ?? false,
      activeDateLabel: 'active',
      activeDate: _formatCardDate(activePrimaryPlan?.startDateTime),
      expireDateLabel: 'expire',
      expireDate: _formatCardDate(activePrimaryPlan?.endDateTime),
    );
  }

  plan_add_ons_models.PlanPurchaseFairUsePolicy _fairUsePolicy() {
    return const plan_add_ons_models.PlanPurchaseFairUsePolicy(
      title: 'fair use policy',
      description:
          'add-ons can only be added to your active primary plan and expires when it ends.',
    );
  }

  plan_add_ons_models.PlanPurchaseAddOnItem _toAddOnTileModel(
    HomePlanAddOnModel addOn,
  ) {
    return plan_add_ons_models.PlanPurchaseAddOnItem(
      id: addOn.id,
      title: addOn.title,
      subtitleLabel: addOn.label,
      subtitleValue: addOn.value,
      price: addOn.price,
      vatAmount: addOn.vatAmount,
    );
  }

  String _formatCardDate(DateTime? date) {
    if (date == null) {
      return '--/--/--';
    }

    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final activePlan = _buildActivePlanSummary();
    final fairUsePolicy = _fairUsePolicy();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _addOnsTabHorizontalPadding,
        20,
        _addOnsTabHorizontalPadding,
        16,
      ),
      children: <Widget>[
        BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
          bloc: instance<DeviceLimitsCubit>(),
          buildWhen: (previous, current) =>
              previous.autoRenew != current.autoRenew ||
              previous.isTogglingAutoRenew != current.isTogglingAutoRenew,
          builder: (context, deviceLimitsState) {
            return PlanPurchasePlanRedImageCard(
              planLabel: activePlan.label,
              planName: activePlan.name,
              activeLabel: activePlan.activeDateLabel,
              activeDate: activePlan.activeDate,
              expireLabel: activePlan.expireDateLabel,
              expireDate: activePlan.expireDate,
              autoRenew: deviceLimitsState.autoRenew,
              // Always pass a callback so the toggle stays in controlled mode
              // (i.e. doesn't fall back to flipping local state on tap). During
              // an in-flight toggle, swallow the tap.
              onAutoRenewChanged: (_) {
                if (deviceLimitsState.isTogglingAutoRenew) return;
                handleAutoRenewToggle(
                  context,
                  currentValue: deviceLimitsState.autoRenew,
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        PlanPurchaseFairUsePolicyCard(
          policy: fairUsePolicy,
          onTap: _openFairUsePolicy,
        ),
        const SizedBox(height: 16),
        ...addOns.map((addOn) {
          final selected = selectedAddOnIds.contains(addOn.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PlanPurchaseAddOnTile(
              item: _toAddOnTileModel(addOn),
              selected: selected,
              onChanged: (_) => onToggleAddOn(addOn),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

class HomePlanAddOnsBottomPayBar extends StatelessWidget {
  const HomePlanAddOnsBottomPayBar({
    super.key,
    required this.state,
    required this.onPayNow,
    this.requireAddOnsTab = true,
  });

  final PlansState state;
  final VoidCallback onPayNow;
  final bool requireAddOnsTab;

  double _selectedAddOnsTotal(PlansState state) {
    return state.addOns
        .where((addOn) => state.selectedAddOnIds.contains(addOn.id))
        .fold<double>(0, (sum, addOn) => sum + addOn.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final tabMismatch =
        requireAddOnsTab && state.selectedTab != HomePlanTab.addOns;
    if (tabMismatch || state.status != PlansStatus.success) {
      return const SizedBox.shrink();
    }

    final total = _selectedAddOnsTotal(state);

    return DefaultBottomPayBar(
      isVatExclusive: false,
      buttonText: 'proceed',
      amountText: '\$ ${total.toStringAsFixed(2)}',
      isButtonEnabled: state.selectedAddOnIds.isNotEmpty,
      onPayNow: onPayNow,
    );
  }
}
