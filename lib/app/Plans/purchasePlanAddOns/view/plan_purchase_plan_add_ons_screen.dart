import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/best_plan_injection.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/auto_renew_actions.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../resources/widgets/default_app_bar.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../bloc/plan_purchase_plan_add_ons_bloc.dart';
import '../bloc/plan_purchase_plan_add_ons_event.dart';
import '../bloc/plan_purchase_plan_add_ons_state.dart';
import '../model/plan_purchase_add_on_models.dart';
import '../model/plan_purchase_plan_add_ons_route_args.dart';
import '../repository/plan_purchase_plan_add_ons_repository.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';
import '../widgets/plan_purchase_add_on_tile.dart';
import '../widgets/plan_purchase_fair_use_policy_card.dart';
import '../widgets/plan_purchase_plan_red_image_card.dart';

class PlanPurchasePlanAddOnsScreen extends StatelessWidget {
  const PlanPurchasePlanAddOnsScreen({super.key, this.routeArgs});

  final PlanPurchasePlanAddOnsRouteArgs? routeArgs;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => PlanPurchasePlanAddOnsRepository(),
      child: BlocProvider(
        create: (ctx) => PlanPurchasePlanAddOnsBloc(
          repository: ctx.read<PlanPurchasePlanAddOnsRepository>(),
        )..add(PlanPurchasePlanAddOnsStarted(routeArgs: routeArgs)),
        child: const _PlanPurchasePlanAddOnsView(),
      ),
    );
  }
}

class _PlanPurchasePlanAddOnsView extends StatelessWidget {
  const _PlanPurchasePlanAddOnsView();

  static const double _defaultPrimaryPlanPrice = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      // Keep each navigation request isolated. Request IDs remain in the bloc
      // after returning from confirmation, so checking their values together
      // can replay an older navigation and push duplicate confirmation screens.
      listeners: [
        BlocListener<PlanPurchasePlanAddOnsBloc, PlanPurchasePlanAddOnsState>(
          listenWhen: (previous, current) =>
              previous.skipRequestId != current.skipRequestId,
          listener: (context, state) => _openConfirmation(
            context,
            state,
            flow: HomePlanConfirmationEntryFlow.skip,
          ),
        ),
        BlocListener<PlanPurchasePlanAddOnsBloc, PlanPurchasePlanAddOnsState>(
          listenWhen: (previous, current) =>
              previous.proceedRequestId != current.proceedRequestId,
          listener: (context, state) => _openConfirmation(
            context,
            state,
            flow: HomePlanConfirmationEntryFlow.proceed,
          ),
        ),
      ],
      child: Scaffold(
        backgroundColor: PlanPurchasePlanAddOnsTheme.bg,
        bottomNavigationBar: const _PlanPurchaseBottomBar(),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              const Expanded(child: _PlanPurchaseBody()),
            ],
          ),
        ),
      ),
    );
  }

  void _openConfirmation(
    BuildContext context,
    PlanPurchasePlanAddOnsState state, {
    required HomePlanConfirmationEntryFlow flow,
  }) {
    context.push(
      AppRoutes.homePlanConfirmationScreen,
      extra: _routeArgsFromState(state, flow: flow),
    );
  }

  DefaultAppBar _buildAppBar(BuildContext context) {
    return DefaultAppBar(
      title: 'add-ons',
      showBackArrow: false,
      actionText: 'skip',
      onActionTextTap: () => context.read<PlanPurchasePlanAddOnsBloc>().add(
        const PlanPurchasePlanAddOnsSkipPressed(),
      ),
      onHomeTap: () => context.go(AppRoutes.home),
    );
  }

  double _extractPrimaryPlanPrice(String planName) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(planName);
    if (match == null) return _defaultPrimaryPlanPrice;
    return double.tryParse(match.group(1) ?? '') ?? _defaultPrimaryPlanPrice;
  }

  HomePlanConfirmationRouteArgs _routeArgsFromState(
    PlanPurchasePlanAddOnsState state, {
    required HomePlanConfirmationEntryFlow flow,
  }) {
    final accountState = instance<AccountInfoCubit>().state;

    return HomePlanConfirmationRouteArgs(
      phoneNumber: _accountUsername(accountState),
      accountHolderName: _accountDisplayName(accountState),
      primaryPlanId: state.selectedApiPlan?.planId.trim() ?? '',
      primaryPlanName: _primaryPlanName(state),
      // Pass the raw API type code so the confirmation repository can decide
      // the display label in one place.
      primaryPlanTypeCode: _primaryPlanTypeCode(state),
      // Confirmation summary shows base prices first; VAT is shown separately
      // in CustomPaymentBreakDownCard.
      primaryPlanPrice: _primaryPlanPriceBeforeVat(state),
      primaryPlanVatAmount: _primaryPlanVatAmount(state),
      futurePlanStartDate: state.selectedApiPlan?.startDate.trim() ?? '',
      flow: flow,
      // Skip means purchasing only the primary plan. Add-ons are forwarded
      // to confirmation only when the user explicitly taps "proceed".
      selectedAddOns: flow == HomePlanConfirmationEntryFlow.proceed
          ? _selectedAddOns(state)
          : const <HomePlanConfirmationSelectedAddOn>[],
      forceNow: state.routeArgs?.forceNow ?? false,
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
    final username = accountState.accountInfo?.username.trim() ?? '';
    return username.isEmpty ? '--' : username;
  }

  String _nameFromEmail(String? email) {
    final normalizedEmail = email?.trim() ?? '';
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'User';
    }

    return normalizedEmail.split('@').first;
  }

  String _primaryPlanName(PlanPurchasePlanAddOnsState state) {
    final selectedPlanName = state.selectedApiPlan?.planName.trim();
    if (selectedPlanName != null && selectedPlanName.isNotEmpty) {
      return selectedPlanName;
    }

    return state.activePlan?.name ?? 'liberty70';
  }

  String _primaryPlanTypeCode(PlanPurchasePlanAddOnsState state) {
    return state.selectedApiPlan?.planType.trim() ?? '';
  }

  double _primaryPlanPriceBeforeVat(PlanPurchasePlanAddOnsState state) {
    final selectedPlan = state.selectedApiPlan;
    if (selectedPlan != null) {
      return selectedPlan.planAmount;
    }

    // Fallback is only used when API plan data is unavailable.
    return _extractPrimaryPlanPrice(_primaryPlanName(state));
  }

  double _primaryPlanVatAmount(PlanPurchasePlanAddOnsState state) {
    return state.selectedApiPlan?.vatAmount ?? 0;
  }

  List<HomePlanConfirmationSelectedAddOn> _selectedAddOns(
    PlanPurchasePlanAddOnsState state,
  ) {
    return state.addOns
        .where((item) => state.selectedAddOnIds.contains(item.id))
        .map(
          (item) => HomePlanConfirmationSelectedAddOn(
            id: item.id,
            title: item.title,
            price: item.price,
            // Each add-on line also shows base price in the summary, while
            // this VAT contributes to the total VAT row.
            vatAmount: item.vatAmount,
            planTypeCode: item.planTypeCode,
          ),
        )
        .toList();
  }
}

class _PlanPurchaseBottomBar extends StatelessWidget {
  const _PlanPurchaseBottomBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanPurchasePlanAddOnsBloc, PlanPurchasePlanAddOnsState>(
      builder: (context, state) {
        if (state.status != PlanPurchasePlanAddOnsStatus.ready) {
          return const SizedBox.shrink();
        }

        return DefaultBottomPayBar(
          isVatExclusive: false,
          buttonText: 'proceed',
          amountText: '\$ ${state.totalPrice.toStringAsFixed(2)}',
          isButtonEnabled: state.selectedAddOnIds.isNotEmpty,
          onPayNow: () => context.read<PlanPurchasePlanAddOnsBloc>().add(
            const PlanPurchasePlanAddOnsProceedPressed(),
          ),
        );
      },
    );
  }
}

class _PlanPurchaseBody extends StatelessWidget {
  const _PlanPurchaseBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanPurchasePlanAddOnsBloc, PlanPurchasePlanAddOnsState>(
      builder: (context, state) {
        switch (state.status) {
          case PlanPurchasePlanAddOnsStatus.initial:
          case PlanPurchasePlanAddOnsStatus.loading:
            return const _LoadingState();
          case PlanPurchasePlanAddOnsStatus.error:
            return _ErrorState(message: state.errorMessage);
          case PlanPurchasePlanAddOnsStatus.ready:
            return _ReadyContent(state: state);
        }
      },
    );
  }
}

class _ReadyContent extends StatelessWidget {
  const _ReadyContent({required this.state});

  final PlanPurchasePlanAddOnsState state;

  static const double _horizontalPadding = 25;

  @override
  Widget build(BuildContext context) {
    //final activePlan = state.activePlan;
    final fairUsePolicy = state.fairUsePolicy;

    if (fairUsePolicy == null) {
      return const _ErrorState(message: 'Failed to load');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        20,
        _horizontalPadding,
        16,
      ),
      children: [
        _ActivePlanCard(state: state),
        const SizedBox(height: 16),
        PlanPurchaseFairUsePolicyCard(
          policy: fairUsePolicy,
          onTap: _openFairUsePolicy,
        ),
        const SizedBox(height: 16),
        ..._buildAddOnTiles(context),
        const SizedBox(height: 4),
      ],
    );
  }

  static final Uri _fairUsePolicyUri = Uri.parse(
    'https://www.bealiv.com/fair-use-policy/',
  );

  Future<void> _openFairUsePolicy() async {
    try {
      final launched = await launchUrl(
        _fairUsePolicyUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      AppToast.show(
        message: 'could not open fair use policy',
        type: ToastType.error,
      );
    }
  }

  List<Widget> _buildAddOnTiles(BuildContext context) {
    if (state.addOns.isEmpty) {
      return const <Widget>[_AddOnsEmptyState()];
    }

    return state.addOns
        .map((item) {
          final selected = state.selectedAddOnIds.contains(item.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PlanPurchaseAddOnTile(
              item: item,
              selected: selected,
              onChanged: (selected) => _toggleAddOn(context, item, selected),
            ),
          );
        })
        .toList(growable: false);
  }

  void _toggleAddOn(
    BuildContext context,
    PlanPurchaseAddOnItem item,
    bool selected,
  ) {
    context.read<PlanPurchasePlanAddOnsBloc>().add(
      PlanPurchasePlanAddOnsSelectionToggled(
        addOnId: item.id,
        selected: selected,
      ),
    );
  }
}

class _ActivePlanCard extends StatefulWidget {
  const _ActivePlanCard({required this.state});

  final PlanPurchasePlanAddOnsState state;

  @override
  State<_ActivePlanCard> createState() => _ActivePlanCardState();
}

class _ActivePlanCardState extends State<_ActivePlanCard> {
  static final DateFormat _cardDateFormat = DateFormat('dd/MM/yy');

  @override
  void initState() {
    super.initState();
    // Ensure DeviceLimitsCubit has data so the toggle reflects the real
    // auto-renew state (mirrors home screen behaviour).
    instance<DeviceLimitsCubit>().loadDeviceLimits();
  }

  @override
  Widget build(BuildContext context) {
    // `selectedApiPlan` comes from routeArgs. It is the real API plan selected
    // on the previous screen.
    final selectedPlan = widget.state.selectedApiPlan;
    final planName = _planNameFromApiOrFallback(selectedPlan?.planName);
    final activeDate = _dateFromApiOrFallback(
      selectedPlan?.startDateTime,
      fallback: '--/--',
    );
    final expireDate = _dateFromApiOrFallback(
      selectedPlan?.endDateTime,
      fallback: '--/--',
    );

    return BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
      bloc: instance<DeviceLimitsCubit>(),
      buildWhen: (previous, current) =>
          previous.autoRenew != current.autoRenew ||
          previous.isTogglingAutoRenew != current.isTogglingAutoRenew,
      builder: (context, deviceLimitsState) {
        return PlanPurchasePlanRedImageCard(
          planLabel: 'active plan',
          planName: planName,
          activeLabel: 'active',
          activeDate: activeDate,
          expireLabel: 'expire',
          expireDate: expireDate,
          autoRenew: deviceLimitsState.autoRenew,
          onAutoRenewChanged: (_) {
            if (deviceLimitsState.isTogglingAutoRenew) return;
            handleAutoRenewToggle(
              context,
              currentValue: deviceLimitsState.autoRenew,
            );
          },
        );
      },
    );
  }

  String _planNameFromApiOrFallback(String? apiPlanName) {
    final name = apiPlanName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return '---';
  }

  String _dateFromApiOrFallback(DateTime? apiDate, {required String fallback}) {
    if (apiDate == null) {
      return fallback;
    }
    return _cardDateFormat.format(apiDate);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message ?? 'Failed to load',
        style: PlanPurchasePlanAddOnsTheme.t(13, weight: FontWeight.w600),
      ),
    );
  }
}

class _AddOnsEmptyState extends StatelessWidget {
  const _AddOnsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'no add-ons available for this plan',
          style: PlanPurchasePlanAddOnsTheme.t(13, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
