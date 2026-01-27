import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown.dart';

import '../home/data/home_ui_config.dart';

class HomeHeader extends StatelessWidget {
  final HomeUiConfig config;
  const HomeHeader({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'aliv',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    config.isPrepaid
                        ? 'active | prepaid'
                        : 'active | postpaid',
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(IconsaxPlusLinear.notification, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome back, Jade!',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const PhoneDropdown(),
        ],
      ),
    );
  }
}
