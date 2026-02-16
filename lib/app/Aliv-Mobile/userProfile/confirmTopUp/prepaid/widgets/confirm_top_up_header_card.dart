import 'package:flutter/material.dart';
import '../theme/confirm_top_up_prepaid_theme.dart';

class ConfirmTopUpHeaderCard extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final double amount;

  const ConfirmTopUpHeaderCard({
    super.key,
    required this.customerName,
    required this.customerPhone,
    required this.amount,
  });

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ConfirmTopUpPrepaidTheme.card,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: ConfirmTopUpPrepaidTheme.titleMd(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customerPhone,
                        style: ConfirmTopUpPrepaidTheme.bodySm(
                          context,
                        ).copyWith(color: ConfirmTopUpPrepaidTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ConfirmTopUpPrepaidTheme.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  'top up',
                  style: ConfirmTopUpPrepaidTheme.titleMd(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFECEBF7),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFF5045A7),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Text(
                        '\$ 15.00',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF5045A7),
                          fontSize: 16,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 14,
                //     vertical: 8,
                //   ),
                //   decoration: BoxDecoration(
                //     border: Border.all(
                //       color: ConfirmTopUpPrepaidTheme.primary,
                //       width: 1.5,
                //     ),
                //     borderRadius: BorderRadius.circular(999),
                //     color: Colors.white,
                //   ),
                //   child: Text(
                //     _money(amount),
                //     style: ConfirmTopUpPrepaidTheme.pillAmount(context),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
