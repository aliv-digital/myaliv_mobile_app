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
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(8, 10),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(customerName, style: RevConfirmationPrepaidTheme.name),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFCDC8F9)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
        Text(service,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
            // style: RevConfirmationPrepaidTheme.service
        ),
        const SizedBox(height: 2),
        Text(
          'acct no. 348340572044',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: const Color(0xFF707070),
            fontSize: 14,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        )
        // Text('acct no. $accountNumber',
        //     // style: RevConfirmationPrepaidTheme.smallMuted
        // ),
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
      child:Text(
        '\$ 200.00',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFF5045A7),
          fontSize: 16,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w500,
        ),
      )
      //Text(text, style: RevConfirmationPrepaidTheme.amountPill),
    );
  }
}
