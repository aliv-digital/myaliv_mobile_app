import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_variant.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/pay_from_wallet/pay_from_wallet_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/pay_from_wallet/pay_from_wallet_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import '../../../../../../router/app_routes.dart';
import '../theme/top_up_prepaid_theme.dart';

class PayFromWalletSheet extends StatelessWidget {
  final double amount;
  final String? phoneNumber;

  const PayFromWalletSheet({super.key, this.amount = 0, this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PayFromWalletCubit>(
      create: (_) => instance<PayFromWalletCubit>(),
      child: _PayFromWalletSheetView(amount: amount, phoneNumber: phoneNumber),
    );
  }
}

class _PayFromWalletSheetView extends StatelessWidget {
  final double amount;
  final String? phoneNumber;

  const _PayFromWalletSheetView({required this.amount, this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: BlocConsumer<PayFromWalletCubit, PayFromWalletState>(
            listener: (context, state) {
              if (state.isSuccess) {
                Navigator.pop(context); // close bottom sheet
                _goToReceipt(context);
              } else if (state.hasError) {
                AppToast.show(
                  message: state.errorMessage ?? 'Transfer failed.',
                  type: ToastType.error,
                );
              }
            },
            builder: (context, state) {
              final isSubmitting = state.isSubmitting;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= HEADER =================
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(-18, 2),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back, size: 24),
                        onPressed: isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Text(
                    'pay from wallet',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= WALLET ROW =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AssetConstant.walletIconSVG,
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          TopUpPrepaidTheme.purple,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Wallet balance',
                        style: TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 14,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF0EDF5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: BlocBuilder<BalanceCubit, BalanceState>(
                          builder: (context, balanceState) {
                            return Text(
                              BalanceCurrencyFormatterService.format(
                                balanceState.walletBalance,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF222222),
                                fontSize: 14,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ================= AMOUNT =================
                  const Text(
                    'amount',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
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

                  const SizedBox(height: 20),

                  // ================= CONFIRM =================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () => _onConfirmPressed(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TopUpPrepaidTheme.purple,
                        disabledBackgroundColor: TopUpPrepaidTheme.purple
                            .withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'confirm payment',
                              style: TextStyle(
                                fontFamily: 'CircularPro',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onConfirmPressed(BuildContext context) {
    final recipient = phoneNumber?.trim();
    if (recipient == null || recipient.isEmpty) {
      AppToast.show(
        message: 'Recipient phone number is missing.',
        type: ToastType.error,
      );
      return;
    }

    context.read<PayFromWalletCubit>().submitTransfer(
      toNumber: recipient,
      amount: amount,
    );
  }

  void _goToReceipt(BuildContext context) {
    context.go(
      AppRoutes.userProfileReceiptScreen,
      extra: UserProfileReceiptRouteArgs(
        amount: amount,
        recipientPhone: phoneNumber,
        paymentMethod: 'wallet',
        title: 'Wallet Transfer Successful!',
        message: 'It may take a few moments before the order is processed.',
        variant: UserProfileReceiptVariant.walletTransfer,
      ),
    );
  }
}
