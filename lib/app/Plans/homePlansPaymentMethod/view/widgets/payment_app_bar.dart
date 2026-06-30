import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/theme/home_plans_payment_method_theme.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Top bar for the payment screen: title + back + home.
class PaymentAppBar extends StatelessWidget {
  const PaymentAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: HomePlansPaymentMethodTheme.appBarHeight,
        child: DefaultAppBar(
          title: 'payment',
          height: HomePlansPaymentMethodTheme.appBarHeight,
          backgroundColor: HomePlansPaymentMethodTheme.appBarBg,
          showBackArrow: true,
          showHome: true,
          onBack: () => context.pop(),
          onHomeTap: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}
