import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

import '../../../router/app_routes.dart';

class PostpaidActivePlanCard extends StatelessWidget {
  final HomeUiConfig config;
  const PostpaidActivePlanCard({super.key, required this.config});

  static const Color red = Color(0xFFD94B4B);
  static const Color lightBg = Color(0xFFF4F5FA);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 190,
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/icons/Home Active Plan.png'),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'active',
                    style: TextStyle(
                      color: Colors.white /* White-100% */,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' plan',
                    style: TextStyle(
                      color: Colors.white /* White-100% */,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),

            Text(
              'liberty prime',
              style: TextStyle(
                color: Colors.white /* White-100% */,
                fontSize: 24,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
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
            const SizedBox(height: 14),

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
                      userType: UserType.prepaid,
                      hasActivePlan: true,
                      openMyLimits: true, // 🔥 KEY LINE
                      isFuturePlan: false
                    ),
                  );
                },
                icon: SvgPicture.asset('assets/icons/card-add.svg',color:Color(0xFFEF3A4B) ,),
                label: const Text(
                  'upgrade credit limit',
                  style: TextStyle(
                    color: const Color(0xFFEF3A4B),
                    fontSize: 13,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
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
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
            fontSize: 10,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white /* White-100% */,
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            letterSpacing: 2.25,
          ),
        ),
      ],
    );
  }
}
