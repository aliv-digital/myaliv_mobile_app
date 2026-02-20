import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/bloc/guest_purchase_plan_receipt_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_receipt_success_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/guest_pay_bill_receipt_bloc.dart';
import '../bloc/guest_pay_bill_receipt_event.dart';
import '../bloc/guest_pay_bill_receipt_state.dart';
import '../model/guest_pay_bill_receipt_args.dart';
import '../repository/guest_pay_bill_receipt_repository.dart';
import '../theme/theme.dart';

class GuestPayBillReceiptScreen extends StatelessWidget {
  const GuestPayBillReceiptScreen({super.key, required this.args});

  final GuestPayBillReceiptArgs args;

  @override
  Widget build(BuildContext context) {
    final normalizedServiceName = args.serviceName.trim().toUpperCase();
    final identifierLabelForReceipt =
        normalizedServiceName == 'REV' ? 'account no.' : args.identifierLabel;

    final receiptData = GuestPayBillReceiptData(
      leftType: 'service',
      rightType: args.serviceName,
      dateText: args.dateText,
      timeText: args.timeText,
      phoneNumber: args.identifierValue,
      identifierLabel: identifierLabelForReceipt,
      paymentMethod: args.paymentMethod,
      amount: args.amount,
    );

    return RepositoryProvider(
      create: (_) => GuestPayBillReceiptRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPayBillReceiptBloc(
          repository: ctx.read<GuestPayBillReceiptRepository>(),
        )..add(GuestPayBillReceiptStarted(receiptData)),
        child: const _GuestPayBillReceiptView(),
      ),
    );
  }
}

class _GuestPayBillReceiptView extends StatelessWidget {
  const _GuestPayBillReceiptView();

  void _onBackHomePressed(BuildContext context) {
    context.read<GuestPayBillReceiptBloc>().add(
          const GuestPayBillReceiptBackToHomePressed(),
        );
  }

  GuestPurchasePlanReceiptData _toDefaultReceiptData(
    GuestPayBillReceiptData data,
  ) {
    return GuestPurchasePlanReceiptData(
      leftType: data.leftType,
      rightType: data.rightType,
      dateText: data.dateText,
      timeText: data.timeText,
      phoneNumber: data.phoneNumber,
      paymentMethod: data.paymentMethod,
      amount: data.amount,
      details: <ReceiptDetailItem>[
        ReceiptDetailItem(label: data.leftType, value: data.rightType),
        ReceiptDetailItem(label: 'date', value: data.dateText),
        ReceiptDetailItem(label: 'time', value: data.timeText),
        ReceiptDetailItem(label: data.identifierLabel, value: data.phoneNumber),
        ReceiptDetailItem(label: 'payment method', value: data.paymentMethod),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestPayBillReceiptBloc, GuestPayBillReceiptState>(
      listenWhen: (previousState, currentState) {
        return previousState.backHomeRequestId != currentState.backHomeRequestId;
      },
      listener: (context, state) {
        if (state.backHomeRequestId > 0) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: GuestPayBillReceiptTheme.screenBackground,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Top app bar
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  backgroundColor: GuestPayBillReceiptTheme.appBarColor,
                  showBackArrow: false,
                  title: 'my receipt',
                  onBack: () {},
                    onHomeTap: () => context.go(AppRoutes.home)

                ),
              ),

              // Main receipt card container
              SliverToBoxAdapter(
                child: Padding(
                  padding: GuestPayBillReceiptTheme.contentPadding,
                  child: BlocBuilder<GuestPayBillReceiptBloc,
                      GuestPayBillReceiptState>(
                    builder: (context, state) {
                      final data = state.data;
                      if (data == null) return const SizedBox.shrink();

                      return DefaultReceiptSuccessCard(
                        data: _toDefaultReceiptData(data),
                        pageBackground: GuestPayBillReceiptTheme.screenBackground,
                        statusMessage:'It will take a few moments for the payment to appear on the account.',
                        onBackHome: () {
                          _onBackHomePressed(context);
                        },
                      );
                    },
                  ),
                ),
              ),

              // SliverToBoxAdapter(
              //   child: Center(
              //     child: ConstrainedBox(
              //       constraints: const BoxConstraints(maxWidth: 420),
              //       child: Padding(
              //         padding: const EdgeInsets.only(
              //           left: 24,
              //           right: 24,
              //           top: 29,
              //           bottom: 30,
              //         ),
              //         child: BlocBuilder<GuestPayBillReceiptBloc,GuestPayBillReceiptState>(
              //           builder: (context, state) {
              //                 final data = state.data;
              //                 if (data == null) return const SizedBox.shrink();

              //                 return PaymentFailedTicket(
              //                   phone: "242-300-2548",
              //                   onPressed: () {
              //                     Navigator.pop(context);
              //                   },
              //                 );
              //               },
              //             ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
