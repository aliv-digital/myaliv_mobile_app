import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/action_tile.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_postpaid.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_usage_section.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/home_header.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/no_active_plan_card.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/postpaid_billing_card.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/prepaid_balance_card.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/view/limited_offer_view.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/view/best_plans_view.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_cards.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:core/core.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color darkPurple = Color(0xFF463C6E); //#463C6E
  static const Color bg = Color(0xFFF6F9FC);
  static const Color yellow = Color(0xFFF9D933);
  static const Color blueBackground = Color(0xFFF1F7FA);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshingToggleStatus = false;

  @override
  void initState() {
    super.initState();
    AppSession.resetAppRoute();

    // Sync the correct toggle status whenever Home opens.
    _refreshToggleStatus();

    // Preload plans in background while user is on home screen
    final userType = context
        .read<AppUiConfigCubit>()
        .state
        .userType;
    context.read<PlansCubit>().loadInitialPlans(userType: userType);

    // BlocListener fires only on state *changes* and misses the synchronous
    // restoration that HydratedCubit performs before the widget subscribes.
    // Sync AppUiConfigCubit here so ActivePlanUsageSection is visible
    // immediately when the cache is warm (success) or stale (refreshing).
    final cachedPlansState = context
        .read<PlansCubit>()
        .state;
    if (cachedPlansState.status == PlansStatus.success ||
        cachedPlansState.status == PlansStatus.refreshing) {
      context
          .read<AppUiConfigCubit>()
          .setHasActivePlan(
        cachedPlansState.earliestAddOnsPrimaryPlan != null,
      );
    }

    // Load limited time offers
    context.read<LimitedOfferCubit>().loadOffers(userType: userType.label);

    // Load best plans
    context.read<BestPlanCubit>().loadPlans(userType: userType.label);

    // Balance, bucket usage summary, and consumption limits are all loaded in
    // _refreshToggleStatus() after DeviceLimitsCubit resolves the DeviceID
    // from GET /Account/devices.
  }

  Future<void> _refreshToggleStatus() async {
    if (_isRefreshingToggleStatus) return;

    _isRefreshingToggleStatus = true;
    try {
      final userType = context
          .read<AppUiConfigCubit>()
          .state
          .userType;

      if (userType.isPostpaid) {
        // Postpaid Auto Pay comes from the Account API.
        await context.read<AccountInfoCubit>().fetchAccountInfo(
          forceRefresh: true,
        );
      }

      // NEW BALANCE FLOW:
      // 1. GET /v1/MyAliv/Account/devices.
      // 2. DeviceLimitsCubit stores the response in allDeviceLimits.
      // 3. deviceLimits selects the first device and exposes its DeviceID.
      // 4. That DeviceID is sent to:
      //    GET /v1/MyAliv/device/{DeviceID}/balances.
      // 5. BalanceCubit stores the wallet and bonus amounts app-wide.
      //
      // Because BalanceCubit is shared, the refreshed value can affect these
      // seven UI/flow areas:
      // 1) prepaid Home top-up/reward balance,
      // 2) postpaid Home balance due,
      // 3) prepaid top-up/send-top-up wallet displays and validation,
      // 4) plan-purchase wallet display and sufficient-balance validation,
      // 5) prepaid auto-renew wallet payment,
      // 6) postpaid make-payment/auto-pay amounts, and
      // 7) upgrade-credit-limit current balance.
      //
      final deviceLimitsCubit = instance<DeviceLimitsCubit>();
      await deviceLimitsCubit.loadDeviceLimits(forceRefresh: true);

      final deviceId = deviceLimitsCubit.state.deviceLimits?.deviceId;
      if (deviceId != null && deviceId > 0) {
        await instance<BalanceCubit>().loadBalances(
          deviceAccountId: deviceId,
          forceRefresh: true,
        );

        // Bucket usage and consumption limits both use DeviceID from
        // /Account/devices so the URLs match /device/{DeviceID}/...
        final plansState = instance<PlansCubit>().state;
        instance<BucketUsageSummaryCubit>().loadBucketUsageSummary(
          deviceAccountId: deviceId,
          activePlans: plansState.activePlansForBucketUsage,
          standAlonePlans: plansState.standAlonePlansForBucketUsage,
          forceRefresh: true,
        );

        final config = context.read<AppUiConfigCubit>().state;
        if (config.userType.isPostpaid) {
          instance<ConsumptionLimitCubit>().loadLimits(
            deviceAccountId: deviceId,
            forceRefresh: true,
          );
        }
      }
    } finally {
      _isRefreshingToggleStatus = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context
        .watch<AppUiConfigCubit>()
        .state;

    return BlocListener<PlansCubit, PlansState>(
      listenWhen: (previous, current) =>
      previous.status != current.status ||
          previous.addOnsApiPrimaryPlans != current.addOnsApiPrimaryPlans ||
          previous.optimisticActivePlan != current.optimisticActivePlan ||
          previous.secondaryPlans != current.secondaryPlans ||
          previous.standAlonePlans != current.standAlonePlans,
      listener: (context, state) {
        if (state.status != PlansStatus.success) return;
        final hasPlan = state.earliestAddOnsPrimaryPlan != null;
        final cubit = context.read<AppUiConfigCubit>();
        if (cubit.state.hasActivePlan != hasPlan) {
          cubit.setHasActivePlan(hasPlan);
        }
        // Keep BucketUsageSummaryCubit's plan sets in sync so its consumers
        // can read planBuckets without touching PlansCubit.
        context.read<BucketUsageSummaryCubit>().updateActivePlans(
          state.activePlansForBucketUsage,
          standAlonePlans: state.standAlonePlansForBucketUsage,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            _headerBackground(),
            SafeArea(
              child: RefreshIndicator(
                // Pulling down syncs Auto Pay or Auto Renew for the user type.
                onRefresh: _refreshToggleStatus,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      HomeHeader(config: config),
                      const SizedBox(height: 16),

                      ///  DIFFERENT CARD BASED ON USER TYPE
                      config.isPrepaid
                          ? const PrepaidBalanceCard()
                          : const PostpaidBillingCard(),

                      const SizedBox(height: 20),

                      BlocBuilder<PlansCubit, PlansState>(
                        buildWhen: (previous, current) =>
                        previous.status != current.status ||
                            previous.addOnsApiPrimaryPlans !=
                                current.addOnsApiPrimaryPlans ||
                            previous.optimisticActivePlan !=
                                current.optimisticActivePlan,
                        builder: (context, plansState) {
                          // While plans are still being fetched, show the active
                          // plan card so its internal skeleton renders. Once the
                          // API resolves, decide from real data instead of the
                          // stale `hasActivePlan` flag.
                          final isResolving =
                              plansState.status == PlansStatus.initial ||
                                  plansState.status == PlansStatus.loading;
                          final showActiveCard =
                              isResolving ||
                                  plansState.earliestAddOnsPrimaryPlan != null;

                          if (!showActiveCard) {
                            return const NoActivePlanCard();
                          }

                          return config.userType == UserType.prepaid
                              ? const PrepaidActivePlanCardWithData(
                            isFromHome: true,
                          ) // TODO
                              : PostpaidActivePlanCard(config: config);
                        },
                      ),

                      config.userType == UserType.prepaid
                          ? const SizedBox(height: 40)
                          : const SizedBox(height: 20),

                      if (config.hasActivePlan)
                        BlocBuilder<BucketUsageSummaryCubit,
                            BucketUsageSummaryState>(
                          buildWhen: (a, b) =>
                          a.status != b.status ||
                              a.activePlans != b.activePlans ||
                              a.summary != b.summary,
                          builder: (context, state) {
                            final isLoading =
                                state.status ==
                                    BucketUsageSummaryStatus.initial ||
                                    state.status ==
                                        BucketUsageSummaryStatus.loading;
                            final isEmpty = !isLoading &&
                                state.activePlanBucketUsage.isEmpty;

                            if (isEmpty) return const SizedBox.shrink();

                            return Container(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F7FA),
                              ),
                              child: const ActivePlanUsageSection(),
                            );
                          },
                        ),

                      BlocBuilder<BucketUsageSummaryCubit,
                          BucketUsageSummaryState>(
                        buildWhen: (a, b) =>
                        a.status != b.status ||
                            a.activePlans != b.activePlans ||
                            a.summary != b.summary,
                        builder: (context, state) {
                          final isEmpty =
                              state.status == BucketUsageSummaryStatus.loaded &&
                                  state.activePlanBucketUsage.isEmpty;
                          return SizedBox(height: isEmpty ? 0 : 20);
                        },
                      ),
                      // my limits — postpaid only, independent of bucket usage
                      if (config.userType.isPostpaid)
                        _myLimitsSection(context),

                      // our best plans
                      _bestPlans(context),

                      // const SizedBox(height: 16),
                      // quick actions
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F7FA),
                        ),
                        child: _quickActions(context, config),
                      ),
                      const SizedBox(height: 24),
                      //count down , yellow limited offers
                      const LimitedOfferView(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER BG =================
  Widget _headerBackground() {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: HomeScreen.purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
    );
  }

  // ================= MY LIMITS =================
  Widget _myLimitsSection(BuildContext context) {
    void open() {
      context.read<AppUiConfigCubit>().showMyLimitsView();
      context.go(AppRoutes.usage);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: const BoxDecoration(color: Color(0xFFF1F7FA)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: open,
                  child: const Text(
                    'my limits',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: open,
                  child: const Text(
                    'view all',
                    style: TextStyle(
                      color: Color(0xFF645D9C),
                      fontSize: 13,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF645D9C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const MyLimitsCards(),
        ],
      ),
    );
  }

  // ================= BEST PLANS =================
  Widget _bestPlans(BuildContext context) {
    return BlocBuilder<BestPlanCubit, BestPlanState>(
      builder: (context, state) {
        // Hide entire section (including title) when no plans available
        if (!state.hasPlans || state.isEmpty) {
          return const SizedBox.shrink();
        }

        return _section(
          title: 'our best plans',
          onViewMore: () {
            context.push(AppRoutes.allBestPlans);
          },
          child: const BestPlansView(),
          color: Colors.white,
        );
      },
    );
  }

  // ================= QUICK ACTIONS =================
  Widget _quickActions(BuildContext context, HomeUiConfig config) {
    return _section(
      title: 'quick actions',
      // onViewMore: () {
      //   context.push(AppRoutes.allBestPlans);
      // },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            GestureDetector(
              onTap: () {
                context.go(AppRoutes.plans);
              },
              child: const ActionTile(
                'assets/icons/ListStarQuick.svg',
                'buy\nplans',
              ),
            ),
            config.userType == UserType.postpaid
                ? GestureDetector(
              onTap: () {
                context.read<AppUiConfigCubit>().showMyLimitsView();
                context.go(AppRoutes.usage);
              },
              child: const ActionTile(
                'assets/icons/SortDescending.svg',
                'update\ncredit limit',
              ),
            )
                : GestureDetector(
              onTap: () {
                context.read<AppUiConfigCubit>().showFuturePlansView();
                context.go(AppRoutes.usage);
              },
              child: const ActionTile(
                'assets/icons/ListHeart.svg',
                'my\nfuture plans',
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.myProfilePrepaidScreen);
              },
              child: const ActionTile('assets/icons/At.svg', 'update\nemail'),
            ),
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.referFriendPrepaidScreen);
              },
              child: const ActionTile(
                'assets/icons/UsersThree.svg',
                'refer a friend',
              ),
            ),
            GestureDetector(
              onTap: () async {
                ///https://www.bealiv.com/deals/
                final uri = Uri.parse('https://www.bealiv.com/deals/');

                if (!await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw 'Could not open store locator';
                }
              },
              child: const ActionTile(
                'assets/icons/aliv_quick.svg',
                'ALIV deals',
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.callSupportScreen);
              },
              child: const ActionTile(
                'assets/icons/headphone.svg',
                'help & support',
              ),
            ),
          ],
        ),
      ),
      color: null,
    );
  }

  Widget _section({
    required String title,
    Color? color,
    required Widget child,
    VoidCallback? onViewMore,
  }) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // 👇 show only if provided
                if (onViewMore != null)
                  GestureDetector(
                    onTap: onViewMore,
                    child: Text(
                      'view all',
                      style: TextStyle(
                        color: const Color(0xFF645D9C),
                        fontSize: 13,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF645D9C),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
