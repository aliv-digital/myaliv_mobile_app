import 'package:flutter/material.dart';
import '../theme/purchase_add_ons_theme.dart';

class PurchaseAddOnsSectionTitleRow extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const PurchaseAddOnsSectionTitleRow({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: PurchaseAddOnsTheme.t(14, weight: FontWeight.w700),
          ),
        ),
        ...(trailing == null ? const <Widget>[] : <Widget>[trailing!]),
      ],
    );
  }
}
