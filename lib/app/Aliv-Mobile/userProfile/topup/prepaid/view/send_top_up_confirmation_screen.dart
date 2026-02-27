import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../confirmTopUp/prepaid/theme/confirm_top_up_prepaid_theme.dart';
import '../../../confirmTopUp/prepaid/widgets/bottom_bar.dart';
import '../../../confirmTopUp/prepaid/widgets/promo_summary_ticket.dart';
import '../widgets/pay_from_wallet.dart';

class SendTopUpConfirmationScreen extends StatelessWidget {
  const SendTopUpConfirmationScreen({super.key});

  // Demo constants
  final String customerName = 'Jade Turnquest';
  final String customerPhone = '242-801-1616';
  final String topUpNumber = '242-899-9999';
  final double amount = 15.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConfirmTopUpPrepaidTheme.background,
      appBar: _appBar(context),
      bottomNavigationBar: ConfirmTopUpBottomBar(
        total: amount,
        vatExclusive: true,
        isLoading: false,
        onContinue: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const PayFromWalletSheet(),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderCard(
                customerName: customerName,
                customerPhone: customerPhone,
                topUpNumber: topUpNumber,
                amount: amount,
              ),

              const SizedBox(height: 14),

              _termsLine(context),

              const SizedBox(height: 16),

              PromoSummaryTicket(
                controller: TextEditingController(),
                onChanged: (_) {},
                onApply: () {},
                subTotal: amount,
                vat: 0.00,
                total: amount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: ConfirmTopUpPrepaidTheme.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'confirmation and payment',
        style: ConfirmTopUpPrepaidTheme.titleMd(
          context,
        ).copyWith(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white),
          onPressed: () {
            // UI only
          },
        ),
      ],
    );
  }

  Widget _termsLine(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: ConfirmTopUpPrepaidTheme.bodySm(
          context,
        ).copyWith(color: ConfirmTopUpPrepaidTheme.textPrimary),
        children: [
          const TextSpan(
            text: 'By pressing “continue” you agree to the ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
          TextSpan(
            text: 'Terms &\nConditions.',
            style: ConfirmTopUpPrepaidTheme.link(context),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final String topUpNumber;
  final double amount;

  const _HeaderCard({
    required this.customerName,
    required this.customerPhone,
    required this.topUpNumber,
    required this.amount,
  });

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ConfirmTopUpPrepaidTheme.card,
        borderRadius: BorderRadius.circular(14),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'top-up prepaid number',
                      style: ConfirmTopUpPrepaidTheme.bodySm(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topUpNumber,
                      style: ConfirmTopUpPrepaidTheme.titleMd(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'immediately',
                      style: ConfirmTopUpPrepaidTheme.bodyMd(context),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ConfirmTopUpPrepaidTheme.primary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white,
                  ),
                  child: Text(
                    _money(amount),
                    style: ConfirmTopUpPrepaidTheme.pillAmount(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
