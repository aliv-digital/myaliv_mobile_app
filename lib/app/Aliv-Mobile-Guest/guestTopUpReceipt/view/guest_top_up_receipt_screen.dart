import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';

import '../bloc/guest_top_up_receipt_bloc.dart';
import '../bloc/guest_top_up_receipt_event.dart';
import '../bloc/guest_top_up_receipt_state.dart';
import '../repository/guest_top_up_receipt_repository.dart';
import '../widgets/receipt_success_card.dart';
import '../widgets/payment_failure.dart';

class GuestTopUpReceiptScreen extends StatelessWidget {
  const GuestTopUpReceiptScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
    required this.dateText,
    required this.timeText,
    this.paymentMethod = 'credit card',
  });

  final String phoneNumber;
  final double amount;
  final String dateText;
  final String timeText;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final receiptData = GuestTopUpReceiptData(
      leftType: 'top up',
      rightType: 'prepaid',
      dateText: dateText,
      timeText: timeText,
      phoneNumber: phoneNumber,
      paymentMethod: paymentMethod,
      amount: amount,
    );

    return RepositoryProvider(
      create: (_) => GuestTopUpReceiptRepository(),
      child: BlocProvider(
        create: (ctx) => GuestTopUpReceiptBloc(
          repository: ctx.read<GuestTopUpReceiptRepository>(),
        )..add(GuestTopUpReceiptStarted(receiptData)),
        child: const _GuestTopUpReceiptView(),
      ),
    );
  }
}

class _GuestTopUpReceiptView extends StatelessWidget {
  const _GuestTopUpReceiptView();

  static const _purple = Color(0xFF655C9A);
  static const _bg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestTopUpReceiptBloc, GuestTopUpReceiptState>(
      listenWhen: (p, c) => p.backHomeRequestId != c.backHomeRequestId,
      listener: (context, state) {
        if (state.backHomeRequestId > 0) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DefaultAppBar(
                    showBackArrow: false,
                      title: 'my receipt',
                      onBack:(){}
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.only(left: 24,right: 24,top: 29,bottom: 30),
                      child: BlocBuilder<GuestTopUpReceiptBloc, GuestTopUpReceiptState>(
                        builder: (context, state) {
                          final data = state.data;
                          if (data == null) return const SizedBox.shrink();
                          return ReceiptSuccessCard(
                            data: data,
                            onBackHome: () {  },
                            pageBackground: ReceiptTheme.circleBackground,
                          );
                        }
                      )
                  )
                ),
                SliverToBoxAdapter(
              //hasScrollBody: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24,right: 24,top: 29,bottom: 30),
                    child: BlocBuilder<GuestTopUpReceiptBloc, GuestTopUpReceiptState>(
                      builder: (context, state) {
                        final data = state.data;
                        if (data == null) return const SizedBox.shrink();

                        return PaymentFailedTicket(
                          phone: "242-300-2548",
                          onPressed: () {
                            Navigator.pop(context); // বা Home route
                          },
                        );
                        // return ReceiptFailureCard(
                        //   data: data,
                        //   pageBackground: _bg,
                        //   onBackHome: () => context.read<GuestTopUpReceiptBloc>().add(
                        //     const GuestTopUpReceiptBackToHomePressed(),
                        //   ),
                        // );
                      },
                    ),
                  ),
                ),
              ),
            ),
              ],
            )
        )
      ),
    );
  }
}
