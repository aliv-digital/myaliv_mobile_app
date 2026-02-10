import 'package:flutter/material.dart';
import '../theme/top_up_prepaid_theme.dart';
import '../view/wallet_transfer_receipt_screen.dart';

class PayFromWalletSheet extends StatelessWidget {
  const PayFromWalletSheet({super.key});


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HANDLE =================
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ================= HEADER =================
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'pay from wallet',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ================= WALLET ROW =================
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined),
                const SizedBox(width: 8),
                const Text(
                  'Wallet balance',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '\$129.00',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= AMOUNT =================
            const Text(
              'amount',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TopUpPrepaidTheme.lightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '\$ 75.00',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= CONFIRM =================
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // UI only
                  Navigator.pop(context); // close bottom sheet
                  _goToReceipt(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TopUpPrepaidTheme.purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'confirm payment',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _goToReceipt(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const WalletTransferReceiptScreen(),
      ),
    );
  }

}
