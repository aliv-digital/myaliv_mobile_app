import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../home/home_screen.dart';
import 'amount_text.dart';

class PostpaidBillingCard extends StatefulWidget {
  const PostpaidBillingCard({super.key});

  @override
  State<PostpaidBillingCard> createState() => _PostpaidBillingCardState();
}

class _PostpaidBillingCardState extends State<PostpaidBillingCard> {
  bool autoPayEnabled = true; // UI-only state

  static const Color purple = Color(0xFF645D9C);
  static const Color lightPurple = Color(0xFFF1F0FA);
  static const Color border = Color(0xFFE6E6EE);
  static const Color textDark = Color(0xFF1E1E2D);
  static const Color textMuted = Color(0xFF8A8A9D);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 18, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= AUTO PAY ROW =================
            Row(
              children: [
                Text(
                  'auto pay',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.32,
                  ),
                ),
                const Spacer(),

                /// TEXT + REAL SWITCH (as in design)
                SizedBox(
                  height: 28,
                  child: Row(
                    children: [
                      Switch(
                        value: autoPayEnabled,
                        onChanged: (value) {
                          setState(() {
                            autoPayEnabled = value;
                          });
                        },
                        activeThumbColor: Colors.white,
                        // activeTrackColor: purple,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFE0E0E8),
                        trackColor: WidgetStateProperty.all(
                          const Color(0xFFE0E0E8),
                        ),
                        thumbColor: WidgetStateProperty.all(purple),
                        splashRadius: 14,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Text(
                        autoPayEnabled ? 'On' : 'Off',
                        style: const TextStyle(
                          color: const Color(0xFF707070),
                          fontSize: 8,
                          fontFamily: 'Circular Pro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= BALANCE DUE =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                // Container(
                //   width: 44,
                //   height: 44,
                //   decoration: BoxDecoration(
                //     color: lightPurple,
                //     borderRadius: BorderRadius.circular(14),
                //   ),
                //   child: const Icon(
                //     Icons.account_balance_wallet_outlined,
                //     color: purple,
                //     size: 24,
                //   ),
                // ),
                SvgPicture.asset('assets/icons/wallet.svg'),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'balance due',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.18,
                          letterSpacing: 0.06,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'payment is due the 15th of each\nmonth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          height: 1.30,
                          letterSpacing: 0.06,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                const OutlinedAmountText(),
                // const Text(
                //   '\$129.00',
                //   style: TextStyle(
                //     fontFamily: 'CircularPro',
                //     fontSize: 24,
                //     fontWeight: FontWeight.w700,
                //     color: purple,
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= PAY NOW BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // UI only
                },
                icon: SvgPicture.asset(
                  'assets/icons/card-add.svg',
                  height: 18,
                  width: 18,
                ),
                label: const Text(
                  'pay now',
                  style: TextStyle(
                    color: const Color(0xFFF1F1F8),
                    fontSize: 13,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w500, // 🔥 NOT WHITE
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
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
