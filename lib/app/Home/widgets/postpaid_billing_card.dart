import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= AUTO PAY ROW =================
            Row(
              children: [
                const Text(
                  'auto pay',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textDark,
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

                        activeTrackColor: purple,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFE0E0E8),
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                      Text(
                        autoPayEnabled ? 'On' : 'Off',
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 14,
                          color: textMuted,
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: purple,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'balance due',
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'payment is due the 15th of each\nmonth',
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 14,
                          height: 1.4,
                          color: textMuted,
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

            const SizedBox(height: 28),

            // ================= PAY NOW BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // UI only
                },
                icon: const Icon(
                  Icons.credit_card,
                  color: Colors.white, // 🔥 NOT WHITE (as per design)
                ),
                label: const Text(
                  'pay now',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // 🔥 NOT WHITE
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


