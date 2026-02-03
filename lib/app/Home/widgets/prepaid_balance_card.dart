import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../home/home_screen.dart';

class PrepaidBalanceCard extends StatelessWidget {
  const PrepaidBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            _row('assets/icons/wallet.svg', 'top up balance', '\$00.00'),
            const SizedBox(height: 12),
            _row('assets/icons/reward.svg', 'reward balance', '\$00.00'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(IconsaxPlusLinear.add, color: Colors.white),
                label: const Text(
                  'add topup',
                  style: TextStyle(fontFamily: 'CircularPro'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String icon, String label, String value) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontFamily: 'CircularPro')),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
