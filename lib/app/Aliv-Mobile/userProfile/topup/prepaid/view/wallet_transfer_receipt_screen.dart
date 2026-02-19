import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../router/app_routes.dart';

class WalletTransferReceiptScreen extends StatelessWidget {
  const WalletTransferReceiptScreen({super.key});

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: const Color(0xFF645D9C),
        elevation: 0,leading: SizedBox(),leadingWidth: 24,
        title: const Text(
          'my receipt',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        // leading:Padding(
        //   padding: const EdgeInsets.only(left: 24),
        //   child: IconButton(
        //     icon: const Icon(Icons.arrow_back,color: Colors.white,),
        //     onPressed: () => Navigator.pop(context),
        //   ),
        // ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [_ReceiptCard(subtotal: 15.00, vat: 0.00, total: 15.00)],
          ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final double subtotal;
  final double vat;
  final double total;

  const _ReceiptCard({
    required this.subtotal,
    required this.vat,
    required this.total,
  });

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 20,
              offset: Offset(0, 10),
              color: Color(0x22000000),
            ),
          ],
        ),
        child: Column(
          children: [
            // ================= ICON =================
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 32,
                color: Color(0xFF4CAF50),
              ),
            ),

            const SizedBox(height: 16),

            // ================= TITLE =================
            const Text(
              'Wallet Transfer Successful!',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'It may take a few moments before the\norder is processed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 12),

            // ================= BREAKDOWN =================
            _row('subtotal', _money(subtotal)),
            const SizedBox(height: 10),
            _row('vat', _money(vat)),

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 14),

            _row('will be transferred', _money(total), isTotal: true),

            const Spacer(),

            // ================= CTA =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.popUntil(context, (r) => r.isFirst);
                  context.go(AppRoutes.home); // ✅ GO TO HOME
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F1FA),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'back to home page',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF645D9C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
