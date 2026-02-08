import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [red, redDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // watermark
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.08,
                child: Text(
                  'aliv',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 140,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topRow(),
                const SizedBox(height: 6),
                _planName(),
                const SizedBox(height: 24),
                _datesRow(),

                // 🔥 CONDITIONAL RENEW BUTTON
                if (showRenewButton) ...[
                  const SizedBox(height: 24),
                  _renewButton(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topRow() {
    return Row(
      children: const [
        Text(
          'active plan',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Spacer(),
        AutoRenewToggle(initialValue: true),
      ],
    );
  }

  Widget _planName() {
    return const Text(
      'liberty70',
      style: TextStyle(
        fontFamily: 'CircularPro',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
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
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4FA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'renew your plan',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: red,
          ),
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
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
