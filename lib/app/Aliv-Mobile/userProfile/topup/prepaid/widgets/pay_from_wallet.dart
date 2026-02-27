import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../router/app_routes.dart';
import '../theme/top_up_prepaid_theme.dart';
import '../view/wallet_transfer_receipt_screen.dart';

class PayFromWalletSheet extends StatelessWidget {
  const PayFromWalletSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        // padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HANDLE =================

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

              const SizedBox(height: 20),

              // ================= WALLET ROW =================
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/icons/Title.svg'),
                    const SizedBox(width: 8),
                    Text(
                      'Wallet balance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF222222),
                        fontSize: 14,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 72,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF8F8FC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            '\$129.00',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF222222),
                              fontSize: 14,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ================= AMOUNT =================
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,),
                child: const Text(
                  'amount',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,),
                child: Container(
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
              ),

              const SizedBox(height: 20),

              // ================= CONFIRM =================
              SizedBox(
                width: double.infinity,
                height: 52,
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
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }

  void _goToReceipt(BuildContext context) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const WalletTransferReceiptScreen()),
    // );
    //
    context.go( AppRoutes.guestTopUpReceipt);
  }
}
