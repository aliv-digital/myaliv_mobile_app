import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/bloc/guest_purchase_plan_receipt_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/repository/guest_purchase_plan_receipt_repository.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../core/utils/app_session.dart';
import '../../../../resources/widgets/default_receipt_success_card.dart';
import '../bloc/guest_purchase_plan_receipt_event.dart';
import '../bloc/guest_purchase_plan_receipt_state.dart';
import '../theme/theme.dart';

class GuestPurchasePlanReceiptScreen extends StatelessWidget {
  const GuestPurchasePlanReceiptScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
    required this.dateText,
    required this.timeText,
    this.paymentMethod = 'credit card',
    this.planName,
    this.addOnNames = const <String>[],
    this.emailAddress = 'guest',
    this.statusMessage =
        'It will take a few moments for the plan to appears on the account.',
  });

  final String phoneNumber;
  final double amount;
  final String dateText;
  final String timeText;
  final String paymentMethod;
  final String? planName;
  final List<String> addOnNames;
  final String emailAddress;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    final details = <ReceiptDetailItem>[
      if ((planName ?? '').isNotEmpty)
        ReceiptDetailItem(label: 'plan', value: planName!, valueBold: false),
      for (final addOn in addOnNames)
        ReceiptDetailItem(label: 'add-on', value: addOn),
      ReceiptDetailItem(label: 'date', value: dateText),
      ReceiptDetailItem(label: 'time', value: timeText),
      ReceiptDetailItem(label: 'phone no.', value: phoneNumber),
      ReceiptDetailItem(label: 'email address', value: emailAddress),
      ReceiptDetailItem(label: 'payment method', value: paymentMethod),
    ];

    final receiptData = GuestPurchasePlanReceiptData(
      leftType: 'service',
      rightType: 'REV',
      dateText: dateText,
      timeText: timeText,
      phoneNumber: phoneNumber,
      paymentMethod: paymentMethod,
      amount: amount,
      details: details,
    );

    return RepositoryProvider(
      create: (_) => GuestPurchasePlanReceiptRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPurchasePlanReceiptBloc(
          repository: ctx.read<GuestPurchasePlanReceiptRepository>(),
        )..add(GuestPurchasePlanReceiptStarted(receiptData)),
        child: _GuestPurchasePlanReceiptView(
          statusMessage: statusMessage,
        ),
      ),
    );
  }
}

class _GuestPurchasePlanReceiptView extends StatelessWidget {
  const _GuestPurchasePlanReceiptView({
    required this.statusMessage,
  });

  static const _bg = Color(0xFFF1F2FA);
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestPurchasePlanReceiptBloc, GuestPurchasePlanReceiptState>(
      listenWhen: (p, c) => p.backHomeRequestId != c.backHomeRequestId,
      listener: (context, state) {
        if (state.backHomeRequestId > 0) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
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
                  child: BlocBuilder<GuestPurchasePlanReceiptBloc, GuestPurchasePlanReceiptState>(
                    builder: (context, state) {
                      final data = state.data;
                      if (data == null) return const SizedBox.shrink();

                      return DefaultReceiptSuccessCard(
                      

                        data: data,
                        onBackHome: () {
                          if(AppSession.appRoute == 'prepaidPlan' || AppSession.appRoute == 'addOnsPrepaid'){
                            context.go(AppRoutes.home);
                            AppSession.resetAppRoute();
                          }else{
                            context.go(AppRoutes.logIn);

                          }
                        },
                        pageBackground: GuestPurchasePlanReceiptTheme.circleBackground,
                        statusMessage: statusMessage,
                      );
                    },
                  ),
                ),
              ),

              /// Failure ticket (if you want to show only on fail later, put condition using state.status)
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
              //         child: BlocBuilder<GuestPurchasePlanReceiptBloc, GuestPurchasePlanReceiptState>(
              //           builder: (context, state) {
              //             final data = state.data;
              //             if (data == null) return const SizedBox.shrink();
              //
              //             return PaymentFailedTicket(
              //               phone: "242-300-2548",
              //               onPressed: () {
              //                 Navigator.pop(context);
              //               },
              //             );
              //           },
              //         ),
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
