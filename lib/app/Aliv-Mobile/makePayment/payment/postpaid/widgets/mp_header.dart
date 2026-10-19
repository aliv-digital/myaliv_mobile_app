import 'package:flutter/material.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../theme/make_payment_postpaid_theme.dart';

/// Top app bar for the make-payment screen. Fixed height, back arrow, and
/// a home shortcut that pops back to the root.
class MpHeader extends StatelessWidget {
  const MpHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      title: title,
      height: MakePaymentPostPaidTheme.appBarHeight,
      backgroundColor: MakePaymentPostPaidTheme.appBarBg,
      showBackArrow: true,
      showHome: true,
      onHomeTap: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
