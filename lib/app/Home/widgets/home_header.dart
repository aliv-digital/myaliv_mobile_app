import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown.dart';

import '../home/data/home_ui_config.dart';

class HomeHeader extends StatelessWidget {
  final HomeUiConfig config;
  const HomeHeader({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/aliv_splash_logo.svg',
                height: 48,
                width: 24,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    config.isPrepaid ? 'active | prepaid' : 'active | postpaid',
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // const Icon(IconsaxPlusLinear.notification, color: Colors.white),
              Stack(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset('assets/icons/Bell.svg'),
                  ),
                  Positioned(
                    left: 20,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFED3434),
                        shape: OvalBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'welcome back, Alicia',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFF1F1F8),
              fontSize: 16,
              fontFamily: 'Circular Pro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const PhoneDropdown(),
        ],
      ),
    );
  }
}
