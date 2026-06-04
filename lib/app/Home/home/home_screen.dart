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
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:core/core.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // /// FLAG → toggle UI
  // final bool hasActivePlan = true;
  // final bool isPrepaid = false;

  static const Color purple = Color(0xFF645D9C);
  static const Color darkPurple = Color(0xFF463C6E); //#463C6E
  static const Color bg = Color(0xFFF6F9FC);
  static const Color yellow = Color(0xFFF9D933);
  static const Color blueBackground = Color(0xFFF1F7FA);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AppSession.resetAppRoute();

    // Preload plans in background while user is on home screen
    final userType = context.read<AppUiConfigCubit>().state.userType;
    context.read<PlansCubit>().loadInitialPlans(userType: userType);

    // Load limited time offers
    context.read<LimitedOfferCubit>().loadOffers(userType: userType.label);

    // Load best plans
    context.read<BestPlanCubit>().loadPlans(userType: userType.label);

    // Load balances and consumption limits
    final accountInfo = context.read<AccountInfoCubit>().state.accountInfo;
    if (accountInfo != null && accountInfo.idAcc > 0) {
      context.read<BalanceCubit>().loadBalances(
        deviceAccountId: accountInfo.idAcc,
      );

      // Load bucket usage summary together with the current plan groups so
      // consumers can read plan-bucket allowance (name/amount/unit) from a
      // single cubit. The plans may still be loading here; the
      // BlocListener<PlansCubit> below re-syncs once PlansCubit emits.
      final plansState = context.read<PlansCubit>().state;
      context.read<BucketUsageSummaryCubit>().loadBucketUsageSummary(
        deviceAccountId: accountInfo.idAcc,
        activePlans: plansState.activePlansForBucketUsage,
        standAlonePlans: plansState.standAlonePlansForBucketUsage,
      );

      // Load device limits for all users (used for name display and credit limits)
      instance<DeviceLimitsCubit>().loadDeviceLimits();

      // Load consumption limits for postpaid users
      if (userType.isPostpaid) {
        instance<ConsumptionLimitCubit>().loadLimits(
          deviceAccountId: accountInfo.idAcc,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return BlocListener<PlansCubit, PlansState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.addOnsApiPrimaryPlans != current.addOnsApiPrimaryPlans ||
          previous.secondaryPlans != current.secondaryPlans ||
          previous.standAlonePlans != current.standAlonePlans,
      listener: (context, state) {
        if (state.status != PlansStatus.success) return;
        final hasPlan = state.addOnsApiPrimaryPlans.isNotEmpty;
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    HomeHeader(config: config),
                    const SizedBox(height: 16),

                    /// 🔥 DIFFERENT CARD BASED ON USER TYPE
                    config.isPrepaid
                        ? const PrepaidBalanceCard()
                        : const PostpaidBillingCard(),

                    const SizedBox(height: 20),

                    BlocBuilder<PlansCubit, PlansState>(
                      buildWhen: (previous, current) =>
                          previous.status != current.status ||
                          previous.addOnsApiPrimaryPlans !=
                              current.addOnsApiPrimaryPlans,
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
                            plansState.addOnsApiPrimaryPlans.isNotEmpty;

                        if (!showActiveCard) {
                          return const NoActivePlanCard();
                        }

                        return config.userType == UserType.prepaid
                            ? const PrepaidActivePlanCardWithData(isFromHome: true,) // TODO
                            : PostpaidActivePlanCard(config: config);
                      },
                    ),

                    config.userType == UserType.prepaid
                        ? const SizedBox(height: 40)
                        : const SizedBox(height: 20),

                    if (config.hasActivePlan)
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F7FA),
                        ),
                        child: const ActivePlanUsageSection(),
                      ),

                    const SizedBox(height: 20),
                    // our best plans
                    _bestPlans(context),

                    // const SizedBox(height: 16),
                    // quick actions
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      decoration: BoxDecoration(color: const Color(0xFFF1F7FA)),
                      child: _quickActions(context, config),
                    ),
                    const SizedBox(height: 24),
                    //count down , yellow limited offers
                    const LimitedOfferView(),
                  ],
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
