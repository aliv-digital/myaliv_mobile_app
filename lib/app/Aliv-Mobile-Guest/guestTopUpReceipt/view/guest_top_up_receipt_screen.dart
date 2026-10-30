import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/guest_top_up_receipt_bloc.dart';
import '../bloc/guest_top_up_receipt_event.dart';
import '../bloc/guest_top_up_receipt_state.dart';
import '../repository/guest_top_up_receipt_repository.dart';
import '../widgets/receipt_failure_card.dart';
import '../widgets/receipt_success_card.dart';

class GuestTopUpReceiptScreen extends StatelessWidget {
  const GuestTopUpReceiptScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
    required this.dateText,
    required this.timeText,
    this.paymentMethod = 'credit card',
    this.orderId,
    this.isPaymentFailed = false,
  });

  final String phoneNumber;
  final double amount;
  final String dateText;
  final String timeText;
  final String paymentMethod;
  final String? orderId;
  final bool isPaymentFailed;

  @override
  Widget build(BuildContext context) {
    final receiptData = GuestTopUpReceiptData(
      leftType: 'top-up',
      rightType: 'prepaid',
      dateText: dateText,
      timeText: timeText,
      phoneNumber: phoneNumber,
      paymentMethod: paymentMethod,
      amount: amount,
      orderId: orderId,
    );

    return RepositoryProvider(
      create: (_) => GuestTopUpReceiptRepository(),
      child: BlocProvider(
        create: (ctx) => GuestTopUpReceiptBloc(
          repository: ctx.read<GuestTopUpReceiptRepository>(),
        )..add(GuestTopUpReceiptStarted(receiptData)),
        child: _GuestTopUpReceiptView(isPaymentFailed: isPaymentFailed),
      ),
    );
  }
}

class _GuestTopUpReceiptView extends StatelessWidget {
  const _GuestTopUpReceiptView({this.isPaymentFailed = false});

  final bool isPaymentFailed;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestTopUpReceiptBloc, GuestTopUpReceiptState>(
      listenWhen: (previous, current) =>
          previous.backHomeRequestId != current.backHomeRequestId,
      listener: (context, state) {
        if (state.backHomeRequestId > 0) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: ReceiptTheme.screenBackground,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  backgroundColor: HexColor.fromHex('#645D9C'),
                  showBackArrow: false,
                  title: 'my receipt',
                  onBack: () {},
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 29,
                    bottom: 30,
                  ),
                  child:
                      BlocBuilder<
                        GuestTopUpReceiptBloc,
                        GuestTopUpReceiptState
                      >(
                        builder: (context, state) {
                          final data = state.data;
                          if (data == null) return const SizedBox.shrink();

                          if (isPaymentFailed) {
                            return ReceiptFailureCard(
                              data: data,
                              onBackHome: () {
                                context.go(AppRoutes.guestSplash);
                              },
                              pageBackground: ReceiptTheme.screenBackground,
                            );
                          }

                          return ReceiptSuccessCard(
                            data: data,
                            onBackHome: () {
                              context.go(AppRoutes.guestSplash);
                            },
                            pageBackground: ReceiptTheme.circleBackground,
                          );
                        },
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
