import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

import '../../../router/app_routes.dart';

class PostpaidActivePlanCard extends StatelessWidget {
  final HomeUiConfig config;
  const PostpaidActivePlanCard( {super.key, required this.config});


  static const Color red = Color(0xFFD94B4B);
  static const Color lightBg = Color(0xFFF4F5FA);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 220,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            // ================= WATERMARK =================
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.08,
                  child: Text(
                    'aliv',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 160,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // ================= CONTENT =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'active plan',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),

                const Text(
                  'liberty prime',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Dates
                Row(
                  children: const [
                    _DateBlock(
                      label: 'active',
                      value: '18/05/24',
                      alignRight: false,
                    ),
                    Spacer(),
                    _DateBlock(
                      label: 'expire',
                      value: '19/06/24',
                      alignRight: true,
                    ),
                  ],
                ),

                const Spacer(),

                // ================= CTA =================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // UI only
                      // context.go(
                      //   AppRoutes.usage,
                      //   extra: config, // 👈 SAME HomeUiConfig
                      // );
                      context.go(
                        AppRoutes.usage,
                        extra: HomeUiConfig(
                          userType: UserType.postpaid,
                          hasActivePlan: true,
                          openMyLimits: true, // 🔥 KEY LINE
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: red,
                    ),
                    label: const Text(
                      'upgrade credit limit',
                      style: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: red,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _DateBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;

  const _DateBlock({
    required this.label,
    required this.value,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

