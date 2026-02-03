import 'package:flutter/material.dart';
import '../model/rev_payment_method_prepaid_models.dart';
import '../theme/rev_payment_method_prepaid_theme.dart';
import 'rev_payment_method_tile.dart';

class RevPaymentMethodSection extends StatelessWidget {
  final List<RevSavedPaymentMethod> methods;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onPayWithCard;

  const RevPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedId,
    required this.onSelect,
    required this.onPayWithCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: RevPaymentMethodPrepaidTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('payment method', style: RevPaymentMethodPrepaidTheme.sectionTitle),
          const SizedBox(height: 10),

          for (final m in methods) ...[
            RevPaymentMethodTile(
              logoSvgAsset: m.logoSvgAsset,
              title: '${_brandText(m)} ending in ${m.ending}',
              subtitle: 'expiry ${m.expiry}',
              selected: selectedId == m.id,
              onTap: () => onSelect(m.id),
            ),
            const SizedBox(height: 10),
          ],

          InkWell(
            onTap: onPayWithCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18, color: RevPaymentMethodPrepaidTheme.plus),
                  const SizedBox(width: 8),
                  Text('pay with card', style: RevPaymentMethodPrepaidTheme.addCard),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18, color: RevPaymentMethodPrepaidTheme.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _brandText(RevSavedPaymentMethod m) {
    switch (m.brand) {
      case RevCardBrand.visa:
        return 'visa';
      case RevCardBrand.mastercard:
        return 'mastercard';
      case RevCardBrand.unknown:
      default:
        return 'card';
    }
  }
}
