import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../repository/make_payment_postpaid_repository.dart';
import '../theme/make_payment_postpaid_theme.dart';

class MpPaymentMethodSection extends StatelessWidget {
  final List<MpPaymentMethod> methods;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddCard;

  const MpPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('payment method', style: MakePaymentPostPaidTheme.methodTitle),
          const SizedBox(height: 10),
          for (int i = 0; i < methods.length; i++) ...[
            _MethodTile(
              method: methods[i],
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
            ),
            if (i != methods.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          InkWell(
            onTap: onAddCard,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18, color: MakePaymentPostPaidTheme.primary),
                  const SizedBox(width: 8),
                  Text('pay with card', style: MakePaymentPostPaidTheme.addCard),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 20, color: MakePaymentPostPaidTheme.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final MpPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? MakePaymentPostPaidTheme.optionSelectedBorder
        : MakePaymentPostPaidTheme.border;
    final nameStyle = selected
        ? MakePaymentPostPaidTheme.methodSelectedName
        : MakePaymentPostPaidTheme.methodName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            _BrandLogo(brand: method.brand),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_brandLabel(method.brand)} ending in ${method.ending}',
                    style: nameStyle,
                  ),
                  const SizedBox(height: 3),
                  Text('expiry ${method.expiry}',
                      style: MakePaymentPostPaidTheme.methodExpiry),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _SelectionIndicator(selected: selected),
          ],
        ),
      ),
    );
  }

  String _brandLabel(MpCardBrand brand) {
    switch (brand) {
      case MpCardBrand.visa:
        return 'visa';
      case MpCardBrand.mastercard:
        return 'mastercard';
    }
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;

  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? MakePaymentPostPaidTheme.primary
        : MakePaymentPostPaidTheme.radioBorder;

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
        color: selected ? MakePaymentPostPaidTheme.primary : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final MpCardBrand brand;

  const _BrandLogo({required this.brand});

  @override
  Widget build(BuildContext context) {
    final isVisa = brand == MpCardBrand.visa;

    return Container(
      width: 46,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: MakePaymentPostPaidTheme.border),
      ),
      child: SvgPicture.asset(
        isVisa ? AssetConstant.visaCardSVG : AssetConstant.masterCardSVG,
        height: 18,
      ),
    );
  }
}
