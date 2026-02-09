import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../router/app_routes.dart';

class UpgradeCreditLimitScreen extends StatelessWidget {
  const UpgradeCreditLimitScreen({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF4F6FB);
  static const Color fieldBg = Color(0xFFF1F0FA);
  static const Color textMuted = Color(0xFF7A7A7A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'upgrade credit limit',
          style: TextStyle(
            fontFamily: 'CircularPro',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: SvgPicture.asset(
                'assets/icons/home.svg',
                color: Colors.white,
              ), //(Icons.home_sharp, color: Colors.white),
              onTap: () {
                context.go(AppRoutes.home);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // ================= CURRENT BALANCE =================
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SvgPicture.asset('assets/icons/Wallet_Cash.svg'),
                  Icon(IconsaxPlusBold.wallet_money, color: purple, size: 28),
                  Column(
                    children: const [
                      // Icon(Icons.account_balance_wallet_outlined,
                      //     color: purple, size: 28),
                      SizedBox(height: 8),
                      Text(
                        '\$129.00',
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: purple,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'current balance',
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= INPUTS =================
            const _LimitField(label: 'local text', value: '30.00'),
            const _LimitField(label: 'local data', value: '30.00'),
            const _LimitField(label: 'local talk mins', value: '30.00'),
            const _LimitField(label: 'int’l roaming', value: '150.00'),
            const _LimitField(label: 'int’l talk mins', value: '150.00'),

            const SizedBox(height: 16),

            // ================= TERMS =================
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 13,
                  color: textMuted,
                ),
                children: [
                  TextSpan(
                    text: 'By pressing "update limits" you agree to the ',
                  ),
                  TextSpan(
                    text: 'terms & conditions.',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: purple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= CTA =================
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // UI only
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'proceed',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

class _LimitField extends StatelessWidget {
  final String label;
  final String value;

  const _LimitField({required this.label, required this.value});

  static const Color fieldBg = Color(0xFFF1F0FA);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
