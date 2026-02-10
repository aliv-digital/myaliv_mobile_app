import 'package:flutter/material.dart';
import '../theme/forget_password_theme.dart';

class ForgetPasswordBottomStripes extends StatelessWidget {
  const ForgetPasswordBottomStripes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Stripe(
          color: ForgetPasswordStripePalette.colors[0],
          height: ForgetPasswordStripePalette.heights[0],
        ),
        _Stripe(
          color: ForgetPasswordStripePalette.colors[1],
          height: ForgetPasswordStripePalette.heights[1],
        ),
        _Stripe(
          color: ForgetPasswordStripePalette.colors[2],
          height: ForgetPasswordStripePalette.heights[2],
        ),
        _Stripe(
          color: ForgetPasswordStripePalette.colors[3],
          height: ForgetPasswordStripePalette.heights[3],
        ),
        _Stripe(
          color: ForgetPasswordStripePalette.colors[4],
          height: ForgetPasswordStripePalette.heights[4],
        ),
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
