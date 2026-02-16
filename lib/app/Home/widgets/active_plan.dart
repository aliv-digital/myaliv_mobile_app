import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'auto_renew_toggle.dart';

class PrepaidActivePlanCard extends StatelessWidget {
  final bool showRenewButton;

  const PrepaidActivePlanCard({
    super.key,
    this.showRenewButton = true, // 🔥 default OFF
  });

  static const Color red = Color(0xFFD94B4B);
  static const Color redDark = Color(0xFFCC3F3F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: showRenewButton
          ? const EdgeInsets.symmetric(horizontal: 24)
          : EdgeInsetsGeometry.zero,
      child: Container(
        height: showRenewButton ? 200 : 160,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/icons/Home Active Plan.png'),
            fit: BoxFit.fill,
          ),
          // gradient: const LinearGradient(
          //   colors: [red, redDark],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topRow(),
            // const SizedBox(height: 6),
            // _planName(),
            const SizedBox(height: 20),
            _datesRow(),
            // 🔥 CONDITIONAL RENEW BUTTON
            if (showRenewButton) ...[
              const SizedBox(height: 14),
              _renewButton(),
            ],
            // showRenewButton? const SizedBox(height: 14):const SizedBox(height: 0),
            // showRenewButton?  _renewButton():const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
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
            _planName(),
          ],
        ),
        Spacer(),
        AutoRenewToggle(initialValue: true),
      ],
    );
  }

  Widget _planName() {
    return Text(
      'liberty70',
      style: TextStyle(
        color: Colors.white /* White-100% */,
        fontSize: 24,
        fontFamily: 'CircularPro',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _datesRow() {
    return Row(
      children: const [
        _DateBlock(title: 'active', value: '20/08/24'),
        Spacer(),
        _DateBlock(title: 'expire', value: '19/09/24', alignRight: true),
      ],
    );
  }

  Widget _renewButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4FA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/card-add.svg',
              width: 18,
              height: 18,
              color: Color(0xFFEF3A4B),
            ),
            SizedBox(width: 10),
            Text(
              'renew your plan',
              style: TextStyle(
                color: const Color(0xFFEF3A4B),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Date Block =================
class _DateBlock extends StatelessWidget {
  final String title;
  final String value;
  final bool alignRight;

  const _DateBlock({
    required this.title,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
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
