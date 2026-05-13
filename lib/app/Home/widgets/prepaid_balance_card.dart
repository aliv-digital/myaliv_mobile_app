import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/Home/home/home_screen.dart';
import 'package:myaliv_mobile_app/app/Home/balance/view/balance_amount_text.dart';

class PrepaidBalanceCard extends StatelessWidget {
  const PrepaidBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 18),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0xFFF1F5F9),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          children: [
            // showing balance from wallet
            _row(
              'assets/icons/wallet.svg',
              'top-up balance',
              const BalanceAmountText(type: BalanceType.wallet),
            ),
            const SizedBox(height: 12),
            _row(
              'assets/icons/reward.svg',
              'reward balance',
              const BalanceAmountText(type: BalanceType.bonus),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                context.push(AppRoutes.topUpPrepaidScreen);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: HomeScreen.purple,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/card-add-pre.svg',
                      width: 21,
                      height: 21,
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 21,
                      child: Text(
                        'add top-up',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFFF1F1F8),
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String icon, String label, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(icon, width: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        valueWidget,
      ],
    );
  }
}

