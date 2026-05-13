import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/utils/appUtils.dart';
import '../theme/top_up_prepaid_theme.dart';

class TopUpPrepaidBalanceRow extends StatelessWidget {
  final double balance;
  final double enteredAmount;
  final bool isSendTopUp;

  const TopUpPrepaidBalanceRow({
    super.key,
    required this.balance,
    this.enteredAmount = 0,
    this.isSendTopUp = false,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (isSendTopUp
            ? balance - enteredAmount
            : balance + enteredAmount)
        .clamp(0, double.infinity);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/wallet.svg',
                  height: 18,
                  width: 18,
                ),
                SizedBox(width: 10),

                Text(
                  'Current Balance will be',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  // width: 63,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF2F2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    AppUtils.formatPrice(remaining),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF222222),
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     // const Icon(Icons.account_balance_wallet_outlined, size: 18, color: TopUpPrepaidTheme.primary),
    //     SvgPicture.asset('assets/icons/wallet.svg', height: 18, width: 18),
    //     const SizedBox(width: 10),
    //     Text('Current Balance', style: TopUpPrepaidTheme.balanceLabel()),
    //     const SizedBox(width: 10),
    //     Container(
    //       width: 64,
    //       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    //       decoration: ShapeDecoration(
    //         color: const Color(0xFFF2F2F2),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(30),
    //         ),
    //       ),
    //       child: Row(
    //         // mainAxisSize: MainAxisSize.min,
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         // spacing: 10,
    //         children: [
    //           Text(
    //             '\$129.00',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //               color: const Color(0xFF222222),
    //               fontSize: 13,
    //               fontFamily: 'CircularPro',
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     // Container(
    //     //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //     //   decoration: BoxDecoration(
    //     //     color: TopUpPrepaidTheme.pillBg,
    //     //     borderRadius: BorderRadius.circular(14),
    //     //   ),
    //     //   child: Text('\$${balance.toStringAsFixed(2)}', style: TopUpPrepaidTheme.pillText()),
    //     // ),
    //   ],
    // );
  }
}
