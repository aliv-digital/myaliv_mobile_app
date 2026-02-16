import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../home/home_screen.dart';

class PrepaidBalanceCard extends StatelessWidget {
  const PrepaidBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16,26,16,18),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0xFFF1F5F9),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          // borderRadius: BorderRadius.circular(8),
          // boxShadow: const [
          //   BoxShadow(color: Colors.black12, blurRadius: 10)
          // ],
        ),
        child: Column(
          children: [
            _row('assets/icons/wallet.svg', 'top-up balance', '\$129.00'),
            const SizedBox(height: 12),
            _row('assets/icons/reward.svg', 'reward balance', '\$308.40'),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: (){},
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: HomeScreen.purple
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/card-add-pre.svg', width: 21, height: 21,),
                    SizedBox(width: 10,),
                    SizedBox(
                      height: 21,
                      child: Text(
                        'add top-up',textAlign: TextAlign.start,
                        style: TextStyle(
                          color: const Color(0xFFF1F1F8),
                          fontSize: 13,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(
            //   width: double.infinity,
            //   height: 50,
            //   child: ElevatedButton.icon(
            //     onPressed: () {},
            //     icon: SvgPicture.asset('assets/icons/card-add-pre.svg', width: 21, height: 21,),
            //
            //     label: Text(
            //       'add topup',textAlign: TextAlign.start,
            //       style: TextStyle(
            //         color: const Color(0xFFF1F1F8),
            //         fontSize: 13,
            //         fontFamily: 'Circular Pro',
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: HomeScreen.purple,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(100),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _row(String icon, String label, String value) {
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
        Text(
          value,
          style: const TextStyle(
            color: const Color(0xFF5045A7),
            fontSize: 24,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
