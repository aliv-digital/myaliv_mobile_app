import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../resources/widgets/common_switch_button.dart';
import '../../../router/app_routes.dart';
import '../home/home_screen.dart';
import 'amount_text.dart';
import 'auto_renew_toggle.dart';
import 'enable_auto_payment_sheet.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.32,
                  ),
                ),
                const Spacer(),

                /// TEXT + REAL SWITCH (as in design)
                // CommonSwitchButton(initialValue: true),
                _FigmaToggle(value: autoPayEnabled, onChanged: onChanged),
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
                  context.push(AppRoutes.makePaymentConfirmationPostpaidScreen);

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
                    fontFamily: 'CircularPro',
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

  void onChanged(bool value) {
    if (value == true) {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const EnableAutoPaymentSheet(),
      ).then((late) {
        setState(() => autoPayEnabled = value);
      });
    }
    setState(() => autoPayEnabled = value);
  }
}

class _FigmaToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FigmaToggle({super.key, required this.value, required this.onChanged});

  static const double _width = 55;
  static const double _height = 28;
  static const double _knobSize = 24;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _width,
        height: _height,
        padding: EdgeInsets.only(left: value ? 10 : 3, right: value ? 3 : 10),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF645D9C) : Colors.white,
          borderRadius: BorderRadius.circular(35.71),
          border: value
              ? null
              : Border.all(width: 0.71, color: const Color(0xFFE2E2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: value
              ? [
                  /// ON TEXT
                  const SizedBox(
                    width: 12,
                    child: Text(
                      'On',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE4E0FF),
                        fontSize: 8,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  /// KNOB
                  _knob(),
                ]
              : [
                  /// KNOB
                  _knob(withShadow: true),

                  /// OFF TEXT
                  const SizedBox(
                    width: 14,
                    child: Text(
                      'Off',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 8,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  static Widget _knob({bool withShadow = false}) {
    return Container(
      width: _knobSize,
      height: _knobSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: withShadow
            ? [
                const BoxShadow(
                  color: Color(0x25000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
    );
  }
}
