import 'package:flutter/material.dart';
import '../theme/login_theme.dart';

class BottomStripes extends StatelessWidget {
  const BottomStripes({super.key});

  static const double kHeight = AuthModuleSizes.stripeTotalHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Stripe(color: AuthModuleStripePalette.colors[0], height: AuthModuleSizes.stripeHeight),
        _Stripe(color: AuthModuleStripePalette.colors[1], height: AuthModuleSizes.stripeHeight),
        _Stripe(color: AuthModuleStripePalette.colors[2], height: AuthModuleSizes.stripeHeight),
        _Stripe(color: AuthModuleStripePalette.colors[3], height: AuthModuleSizes.stripeHeight),
        _Stripe(color: AuthModuleStripePalette.colors[4], height: AuthModuleSizes.stripeHeight),
      ],
    );
  }
}

class _Stripe extends StatelessWidget {
  final Color color;
  final double height;

  const _Stripe({required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: color,
    );
  }
}
