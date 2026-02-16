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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: purple,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: const Icon(Icons.arrow_back,color: Colors.white,),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'upgrade credit limit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0,8,20,8),
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
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFEAECF0),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Image.asset('assets/icons/Wallet_Cash_550px 1.png',width: 36,height: 40,),
                  // Icon(IconsaxPlusBold.wallet_money, color: purple, size: 28),
                  SizedBox(width: 14),

                  Column(
                    children: const [
                      // Icon(Icons.account_balance_wallet_outlined,
                      //     color: purple, size: 28),
                      Text(
                        '\$129.00',
                        style: TextStyle(
                          color: const Color(0xFF5045A7),
                          fontSize: 24,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'current balance',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
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
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'B',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                  TextSpan(
                    text: 'y pressing “update limits” you agree to the ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                  TextSpan(
                    text: 'terms & conditions',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      height: 1.43,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= CTA =================
            Padding(
              padding: const EdgeInsets.only(left: 16.0,right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 40,
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
                      color: const Color(0xFFF1F1F8),
                      fontSize: 13,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: const Color(0xFF1C1C1C) /* Black-100% */,
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: ShapeDecoration(
              color: const Color(0xFFF1F1F8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Uber Move Text',
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: const Color(0xFF707070),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
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
