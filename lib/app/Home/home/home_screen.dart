import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/data/plan_icon_assets.dart';

import '../../../resources/constants/asset_constants.dart';
import '../../../router/app_routes.dart';
import '../model/demo_plans.dart';
import '../widgets/action_tile.dart';
import '../widgets/active_plan.dart';
import '../widgets/active_plan_card_postpaid.dart';
import '../widgets/active_plan_usage_section.dart';
import '../widgets/home_header.dart';
import '../widgets/phone_dropdown.dart';
import '../widgets/plan_card.dart';
import '../widgets/postpaid_billing_card.dart';
import '../widgets/prepaid_balance_card.dart';
import '../widgets/timer.dart';
import 'data/home_ui_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // /// FLAG → toggle UI
  // final bool hasActivePlan = true;
  // final bool isPrepaid = false;

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF6F9FC);
  static const Color yellow = Color(0xFFF9D933);
  static const Color blueBackground = Color(0xFFF1F7FA);

  final HomeUiConfig config = const HomeUiConfig(
    userType: UserType.prepaid, // 🔥 switch here for demo
    hasActivePlan: true,
    isFuturePlan: false,
  );

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
                  _limitedOffer(),
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
        color: purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
    );
  }

  // ================= TOP HEADER =================
  // Widget _topHeader() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // top row
  //         Row(
  //           children: [
  //             const Text(
  //               'aliv',
  //               style: TextStyle(
  //                 fontFamily: 'CircularPro',
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.w700,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             const Spacer(),
  //             Row(
  //               children: const [
  //                 Icon(Icons.circle, size: 8, color: Colors.greenAccent),
  //                 SizedBox(width: 6),
  //                 Text(
  //                   'active | prepaid',
  //                   style: TextStyle(
  //                     fontFamily: 'CircularPro',
  //                     color: Colors.white,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(width: 12),
  //             const Icon(IconsaxPlusLinear.notification, color: Colors.white),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'Welcome back, Jade!',
  //           style: TextStyle(
  //             fontFamily: 'CircularPro',
  //             fontSize: 16,
  //             color: Colors.white,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         const PhoneDropdown(),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _topHeaderPostpaid() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // top row
  //         Row(
  //           children: [
  //             const Text(
  //               'aliv',
  //               style: TextStyle(
  //                 fontFamily: 'CircularPro',
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.w700,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             const Spacer(),
  //             Row(
  //               children: [
  //                 const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
  //                 const SizedBox(width: 6),
  //                 Text(
  //                   config.userType == UserType.prepaid
  //                       ? 'active | prepaid'
  //                       : 'active | postpaid',
  //                   style: const TextStyle(
  //                     fontFamily: 'CircularPro',
  //                     color: Colors.white,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(width: 12),
  //             const Icon(IconsaxPlusLinear.notification, color: Colors.white),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'Welcome back, Jade!',
  //           style: TextStyle(
  //             fontFamily: 'CircularPro',
  //             fontSize: 16,
  //             color: Colors.white,
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         const PhoneDropdown(),
  //       ],
  //     ),
  //   );
  // }
  //
  // // ================= BALANCE CARD =================
  // Widget _balanceCard() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20),
  //         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
  //       ),
  //       child: Column(
  //         children: [
  //           _balanceRow('assets/icons/wallet.svg', 'top up balance', '\$00.00'),
  //           const SizedBox(height: 12),
  //           _balanceRow('assets/icons/reward.svg', 'reward balance', '\$00.00'),
  //           const SizedBox(height: 16),
  //           SizedBox(
  //             width: double.infinity,
  //             height: 44,
  //             child: ElevatedButton.icon(
  //               onPressed: () {},
  //               icon: const Icon(IconsaxPlusLinear.add, color: Colors.white),
  //               label: const Text(
  //                 'add topup',
  //                 style: TextStyle(
  //                   fontFamily: 'CircularPro',
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: purple,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(24),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _balanceRow(String icon, String label, String value) {
  //   return Row(
  //     children: [
  //       SvgPicture.asset(icon, width: 22, height: 22, fit: BoxFit.contain),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: Text(
  //           label,
  //           style: const TextStyle(fontSize: 12, fontFamily: 'CircularPro'),
  //         ),
  //       ),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           fontFamily: 'CircularPro',
  //           fontSize: 18,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ================= NO ACTIVE PLAN =================
  Widget _noActivePlan(BuildContext context) {
    return Container(
      color: blueBackground,
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
              side: const BorderSide(color: purple),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'purchase a new plan',
                style: TextStyle(fontFamily: 'CircularPro', color: purple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTIVE PLAN =================

  // ================= BEST PLANS =================
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
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, index) {
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
          children: const [
            ActionTile('assets/icons/ListStar.svg', 'buy\nplans'),
            ActionTile('assets/icons/ListHeart.svg', 'my\nfuture plans'),
            ActionTile('assets/icons/At.svg', 'update\nemail'),
            ActionTile('assets/icons/UsersThree.svg', 'refer a friend'),
            ActionTile('assets/icons/aliv.svg', 'ALIV\ndeals'),
            ActionTile('assets/icons/headphone.svg', 'help & support'),
          ],
        ),
      ),
      color: null,
    );
  }

  // ================= LIMITED OFFER =================
  Widget _limitedOffer() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(14, 18, 12, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Limited \nTime Offer',
                      style: TextStyle(
                        color: const Color(
                          0xFF101828,
                        ) /* Colors-Text-text-primary-(900) */,
                        fontSize: 20,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.10,
                      ),
                    ),
                    Text(
                      'See the best product now',
                      style: TextStyle(
                        color: const Color(
                          0xFF101828,
                        ) /* Colors-Text-text-primary-(900) */,
                        fontSize: 10,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.05,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              TimerBox('00', 'Days'),
              TimerBox('03', 'Hours'),
              TimerBox('55', 'Min'),
              TimerBox('29', 'Sec'),
            ],
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

                    child: const Text(
                      'view more',
                      style: TextStyle(
                        color: const Color(0xFF007AD0),
                        fontSize: 12,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
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
