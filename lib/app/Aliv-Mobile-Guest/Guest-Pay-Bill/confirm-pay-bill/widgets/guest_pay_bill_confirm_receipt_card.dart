import 'package:flutter/material.dart';
import '../theme/guest_pay_bill_confirm_theme.dart';

class GuestPayBillConfirmReceiptCard extends StatelessWidget {
  final double subTotal;
  final double vat;
  final double total;

  const GuestPayBillConfirmReceiptCard({
    super.key,
    required this.subTotal,
    required this.vat,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          decoration: BoxDecoration(
            color: GuestPayBillConfirmTheme.receiptBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _RowLine(label: 'sub total', value: _money(subTotal)),
              const SizedBox(height: 10),
              _RowLine(label: 'vat', value: _money(vat)),
              const SizedBox(height: 12),
              _DashedLine(),
              const SizedBox(height: 12),
              _RowLine(label: 'total', value: _money(total)),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -10,
          child: _ScallopRow(),
        ),
      ],
    );
  }

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';
}

class _RowLine extends StatelessWidget {
  final String label;
  final String value;

  const _RowLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: GuestPayBillConfirmTheme.receiptLabel()),
        const Spacer(),
        Text(value, style: GuestPayBillConfirmTheme.receiptValue()),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count = (c.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              color: Colors.white.withOpacity(0.7),
            );
          }),
        );
      },
    );
  }
}

class _ScallopRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        const r = 7.0;
        final count = (c.maxWidth / (r * 2)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return Container(
              width: r * 2,
              height: r * 2,
              decoration: const BoxDecoration(
                color: GuestPayBillConfirmTheme.pageBg,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
