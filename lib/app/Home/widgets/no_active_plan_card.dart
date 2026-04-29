import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/home_screen.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Empty state shown on the home screen when the user has no active plan.
/// CTA navigates to the plans tab so the user can pick one.
class NoActivePlanCard extends StatelessWidget {
  const NoActivePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeScreen.blueBackground,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _IconBadge(),
          const SizedBox(height: 16),
          const Text(
            'you currently do not have an active plan',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF707070),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _PurchasePlanButton(onPressed: () => context.go(AppRoutes.plans)),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75.0,
      height: 75.0,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/no_plan.svg',
          width: 65.0,
          height: 65.0,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _PurchasePlanButton extends StatelessWidget {
  const _PurchasePlanButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: HomeScreen.purple,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
        child: const Text(
          'purchase a new plan',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: HomeScreen.purple,
          ),
        ),
      ),
    );
  }
}
