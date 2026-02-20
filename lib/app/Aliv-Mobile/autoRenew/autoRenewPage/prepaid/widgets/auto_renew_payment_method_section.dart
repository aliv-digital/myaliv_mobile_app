import 'package:flutter/material.dart';
import '../models/auto_renew_prepaid_models.dart';
import '../theme/auto_renew_prepaid_theme.dart';
import 'auto_renew_payment_method_tile.dart';

class AutoRenewPaymentMethodSection extends StatelessWidget {
  final List<AutoRenewPaymentMethod> methods;
  final String? selectedMethodId;
  final ValueChanged<String> onSelect;

  const AutoRenewPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedMethodId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AutoRenewPrepaidTheme.cardBg,
        borderRadius:
            BorderRadius.circular(AutoRenewPrepaidTheme.sectionRadius),
      ),
      padding: AutoRenewPrepaidTheme.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select payment method',
            style: AutoRenewPrepaidTheme.sectionTitleStyle,
          ),
          const SizedBox(height: AutoRenewPrepaidTheme.sectionTitleGap),
          for (int i = 0; i < methods.length; i++) ...[
            AutoRenewPaymentMethodTile(
              method: methods[i],
              selected: methods[i].id == selectedMethodId,
              onTap: () => onSelect(methods[i].id),
            ),
            if (i != methods.length - 1)
              const SizedBox(height: AutoRenewPrepaidTheme.sectionItemGap),
          ],
        ],
      ),
    );
  }
}
