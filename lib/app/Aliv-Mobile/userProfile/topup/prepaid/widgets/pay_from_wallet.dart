import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import '../../../../../../router/app_routes.dart';
import '../theme/top_up_prepaid_theme.dart';

class PayFromWalletSheet extends StatelessWidget {
  final double amount;

  const PayFromWalletSheet({super.key, this.amount = 0});

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
                          BlocBuilder<BalanceCubit, BalanceState>(
                            builder: (context, balanceState) {
                              return Text(
                                '\$${balanceState.walletBalanceFormatted}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF222222),
                                  fontSize: 14,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
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
                  child: Text(
                    '\$ ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF707070),
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
    context.go(
      AppRoutes.userProfileReceiptScreen,
      extra: UserProfileReceiptRouteArgs(
        amount: amount,
        paymentMethod: 'wallet',
        title: 'Wallet Transfer Successful!',
        message: 'It may take a few moments before the order is processed.',
      ),
    );
  }
}
