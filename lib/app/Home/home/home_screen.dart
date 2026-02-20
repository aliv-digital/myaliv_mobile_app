import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_session.dart';
import '../../../router/app_routes.dart';
import '../model/demo_plans.dart';
import '../widgets/action_tile.dart';
import '../widgets/active_plan.dart';
import '../widgets/active_plan_card_postpaid.dart';
import '../widgets/active_plan_usage_section.dart';
import '../widgets/home_header.dart';
import '../widgets/plan_card.dart';
import '../widgets/postpaid_billing_card.dart';
import '../widgets/prepaid_balance_card.dart';
import '../widgets/timer.dart';
import 'data/home_ui_config.dart';

final HomeUiConfig config = const HomeUiConfig(
  userType: UserType.prepaid, // 🔥 switch here for demo
  hasActivePlan: true,
  isFuturePlan: false,
);

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
    AppSession.resetAppRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _headerBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  HomeHeader(config: config),
                  const SizedBox(height: 16),

                  /// 🔥 DIFFERENT CARD BASED ON USER TYPE
                  config.isPrepaid
                      ? const PrepaidBalanceCard()
                      : const PostpaidBillingCard(),

                  const SizedBox(height: 20),

                  config.hasActivePlan
                      ? config.userType == UserType.prepaid
                            ? PrepaidActivePlanCard()
                            : PostpaidActivePlanCard(config: config)
                      : _noActivePlan(context),

                  config.userType == UserType.prepaid
                      ? const SizedBox(height: 40)
                      : const SizedBox(height: 20),

                  if (config.hasActivePlan)
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      decoration: BoxDecoration(color: const Color(0xFFF1F7FA)),
                      child: const ActivePlanUsageSection(),
                    ),

                  const SizedBox(height: 20),
                  _bestPlans(context),

                  // const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    decoration: BoxDecoration(color: const Color(0xFFF1F7FA)),
                    child: _quickActions(context),
                  ),
                  const SizedBox(height: 24),
                  _limitedOffer(context),
                ],
              ),
            ),
          ),
        ],
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

  Widget _noActivePlan(BuildContext context) {
    return Container(
      color: HomeScreen.blueBackground,
      width: MediaQuery.of(context).size.width,
      height: 190,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon(IconsaxPlusLinear.receipt_minus, color: Colors.grey),
          SvgPicture.asset(
            'assets/icons/no_plan.svg',
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            'you currently do not have an active plan',
            style: TextStyle(fontFamily: 'CircularPro', color: Colors.grey),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              side: const BorderSide(color: HomeScreen.purple),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'purchase a new plan',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  color: HomeScreen.purple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTIVE PLAN =================
  Widget _bestPlans(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.75; // 🔥 3/4 width

    return _section(
      title: 'our best plans',
      onViewMore: () {
        context.push(AppRoutes.allBestPlans);
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        height: 170,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 11),
          scrollDirection: Axis.horizontal,
          itemCount: demoPlans.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return SizedBox(
              width: cardWidth,
              child: PlanCard(
                plan: demoPlans[index],
                height: 170,
                imageWidth: cardWidth * 0.4, // 🔥 image scales too
              ),
            );
          },
        ),
      ),
      color: Colors.white,
    );
  }

  // ================= QUICK ACTIONS =================
  Widget _quickActions(BuildContext context) {
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
            const ActionTile('assets/icons/ListStarQuick.svg', 'buy\nplans'),
            config.userType == UserType.postpaid
                ? const ActionTile(
                    'assets/icons/SortDescending.svg',
                    'update\ncredit limit',
                  )
                : const ActionTile(
                    'assets/icons/ListHeart.svg',
                    'my\nfuture plans',
                  ),
            const ActionTile('assets/icons/At.svg', 'update\nemail'),
            const ActionTile('assets/icons/UsersThree.svg', 'refer a friend'),
            const ActionTile('assets/icons/aliv_quick.svg', 'ALIV deals'),
            const ActionTile('assets/icons/headphone.svg', 'help & support'),
          ],
        ),
      ),
      color: null,
    );
  }

  // ================= LIMITED OFFER =================
  Widget _limitedOffer(BuildContext context) {
    const timers = [
      ('00', 'Days'),
      ('03', 'Hours'),
      ('55', 'Min'),
      ('29', 'Sec'),
    ];

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 11, 24, 15),
        child: Container(
          width: double.infinity,
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: HomeScreen.yellow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final timerGap = constraints.maxWidth < 320 ? 4.0 : 6.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Limited \nTime Offer',
                          style: TextStyle(
                            color: Color(0xFF101828),
                            fontSize: 40 / 2,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'See the best product now',
                          style: TextStyle(
                            color: Color(0xFF101828),
                            fontSize: 10,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 7,
                    child: Row(
                      children: [
                        for (int i = 0; i < timers.length; i++) ...[
                          if (i > 0) SizedBox(width: timerGap),
                          Expanded(
                            child: TimerBox(
                              timers[i].$1,
                              timers[i].$2,
                              compact: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
