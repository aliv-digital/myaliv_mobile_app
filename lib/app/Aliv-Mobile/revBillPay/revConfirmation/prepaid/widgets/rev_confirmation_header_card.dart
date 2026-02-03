import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import '../theme/rev_confirmation_prepaid_theme.dart';

class RevConfirmationHeaderCard extends StatelessWidget {
  final String customerName;
  final String service;
  final String accountNumber;
  final String amountText;

  const RevConfirmationHeaderCard({
    super.key,
    required this.customerName,
    required this.service,
    required this.accountNumber,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RevConfirmationPrepaidTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(customerName, style: RevConfirmationPrepaidTheme.name),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6F2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _ServiceBlock(
                    service: service,
                    accountNumber: accountNumber,
                  ),
                ),
                _AmountPill(text: amountText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceBlock extends StatelessWidget {
  final String service;
  final String accountNumber;

  const _ServiceBlock({
    required this.service,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(service, style: RevConfirmationPrepaidTheme.service),
        const SizedBox(height: 2),
        Text('acct no. $accountNumber', style: RevConfirmationPrepaidTheme.smallMuted),
      ],
    );
  }
}

class _AmountPill extends StatelessWidget {
  final String text;
  const _AmountPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HexColor.fromHex('#EDEBF7'),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RevConfirmationPrepaidTheme.amountPillBorder, width: 1),
      ),
      child: Text(text, style: RevConfirmationPrepaidTheme.amountPill),
    );
  }
}
