import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
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

  static const String _defaultPhone = '242-801-1616';
  static const String _defaultAccountHolder = 'Jade Turnquest';
  static const double _defaultPrimaryPlanPrice = 70;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlanPurchasePlanAddOnsBloc,
        PlanPurchasePlanAddOnsState>(
      listenWhen: _shouldHandleNavigation,
      listener: _handleNavigation,
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

  bool _shouldHandleNavigation(PlanPurchasePlanAddOnsState previous,
      PlanPurchasePlanAddOnsState current) {
    return previous.skipRequestId != current.skipRequestId ||
        previous.proceedRequestId != current.proceedRequestId;
  }

  void _handleNavigation(
      BuildContext context, PlanPurchasePlanAddOnsState state) {
    if (state.skipRequestId > 0) {
      _openConfirmation(
        context,
        state,
        flow: HomePlanConfirmationEntryFlow.skip,
      );
    }

    if (state.proceedRequestId > 0) {
      _openConfirmation(
        context,
        state,
        flow: HomePlanConfirmationEntryFlow.proceed,
      );
    }
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
    return HomePlanConfirmationRouteArgs(
      phoneNumber: _defaultPhone,
      accountHolderName: _defaultAccountHolder,
      primaryPlanName: _primaryPlanName(state),
      primaryPlanPrice: _primaryPlanPrice(state),
      flow: flow,
      selectedAddOns: _selectedAddOns(state),
    );
  }

  String _primaryPlanName(PlanPurchasePlanAddOnsState state) {
    final selectedPlanName = state.selectedApiPlan?.planName.trim();
    if (selectedPlanName != null && selectedPlanName.isNotEmpty) {
      return selectedPlanName;
    }

    return state.activePlan?.name ?? 'liberty70';
  }

  double _primaryPlanPrice(PlanPurchasePlanAddOnsState state) {
    final selectedPlan = state.selectedApiPlan;
    if (selectedPlan != null) {
      return selectedPlan.planAmount + selectedPlan.vatAmount;
    }

    return _extractPrimaryPlanPrice(_primaryPlanName(state));
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
          isVatExclusive: true,
          buttonText: 'proceed',
          amountText: '\$ ${state.totalPrice.toStringAsFixed(2)}',
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

    if ( fairUsePolicy == null) {
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
        PlanPurchaseFairUsePolicyCard(policy: fairUsePolicy, onTap: () {}),
        const SizedBox(height: 16),
        ..._buildAddOnTiles(context),
        const SizedBox(height: 4),
      ],
    );
  }

  List<Widget> _buildAddOnTiles(BuildContext context) {
    if (state.addOns.isEmpty) {
      return const <Widget>[_AddOnsEmptyState()];
    }

    return state.addOns.map((item) {
      final selected = state.selectedAddOnIds.contains(item.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: PlanPurchaseAddOnTile(
          item: item,
          selected: selected,
          onChanged: (selected) => _toggleAddOn(context, item, selected),
        ),
      );
    }).toList(growable: false);
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

class _ActivePlanCard extends StatelessWidget {
  const _ActivePlanCard({required this.state});

  final PlanPurchasePlanAddOnsState state;
  //final PlanPurchaseActivePlanSummary activePlan;

  static final DateFormat _cardDateFormat = DateFormat('dd/MM/yy');

  @override
  Widget build(BuildContext context) {
    // `selectedApiPlan` comes from routeArgs. It is the real API plan selected
    // on the previous screen. `activePlan` is kept only as a fallback summary.
    final selectedPlan = state.selectedApiPlan;
    final planName = _planNameFromApiOrFallback(selectedPlan?.planName);
    final activeDate = _dateFromApiOrFallback(
      selectedPlan?.startDateTime,
      fallback: "--/--"//activePlan.activeDate,
    );
    final expireDate = _dateFromApiOrFallback(
      selectedPlan?.endDateTime,
      fallback: "--/--"//activePlan.expireDate,
    );

    return PlanPurchasePlanRedImageCard(
      planLabel: 'active plan',//activePlan.label,
      planName: planName,
      activeLabel: 'active',//activePlan.activeDateLabel,
      activeDate: activeDate,
      expireLabel: 'expire',//activePlan.expireDateLabel,
      expireDate: expireDate,
      autoRenew: state.autoRenew,
      onAutoRenewChanged: (value) {
        context.read<PlanPurchasePlanAddOnsBloc>().add(
              PlanPurchasePlanAddOnsAutoRenewToggled(value),
            );
      },
    );
  }

  String _planNameFromApiOrFallback(String? apiPlanName) {
    final name = apiPlanName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return '---';//activePlan.name;
  }

  String _dateFromApiOrFallback(DateTime? apiDate, {required String fallback}) {
    if (apiDate == null) {
      return fallback;
    }

    // API format example: "2022-06-09 19:14:00".
    // BasePlanModel parses that into DateTime, then we show "09/06/22".
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
