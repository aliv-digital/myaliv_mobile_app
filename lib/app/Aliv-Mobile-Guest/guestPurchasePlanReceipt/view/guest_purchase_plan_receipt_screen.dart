import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/utils/guest_plan_phone_formatter.dart';
import 'package:myaliv_mobile_app/app/common/services/plan_name_formatter_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/bloc/guest_purchase_plan_receipt_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/bloc/guest_purchase_plan_receipt_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/bloc/guest_purchase_plan_receipt_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/repository/guest_purchase_plan_receipt_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/theme/theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanReceipt/widgets/receipt_failure_card.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_receipt_success_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

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
    this.orderId,
    this.isPaymentFailed = false,
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
  final String? orderId;
  final bool isPaymentFailed;

  @override
  Widget build(BuildContext context) {
    final details = <ReceiptDetailItem>[
      if ((planName ?? '').isNotEmpty)
        ReceiptDetailItem(
          label: 'plan',
          value: PlanNameFormatterService.format(planName!),
          valueBold: false,
        ),
      for (final addOn in addOnNames)
        ReceiptDetailItem(label: 'add-on', value: addOn),
      if (orderId != null && orderId!.isNotEmpty)
        ReceiptDetailItem(
          label: 'order reference',
          value: orderId!,
          valueBold: false,
        ),
      ReceiptDetailItem(label: 'date', value: dateText),
      ReceiptDetailItem(label: 'time', value: timeText),
      ReceiptDetailItem(
        label: 'phone no.',
        value: GuestPlanPhoneFormatter.format(phoneNumber, isBahamas: true),
      ),
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
          isPaymentFailed: isPaymentFailed,
          statusMessage: (int.tryParse(orderId ?? '') ?? 0) > 0
              ? 'The plan was purchased successfully.'
              : statusMessage,
        ),
      ),
    );
  }
}

class _GuestPurchasePlanReceiptView extends StatelessWidget {
  const _GuestPurchasePlanReceiptView({
    required this.statusMessage,
    this.isPaymentFailed = false,
  });

  static const _bg = Color(0xFFF1F2FA);
  final String statusMessage;
  final bool isPaymentFailed;

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      GuestPurchasePlanReceiptBloc,
      GuestPurchasePlanReceiptState
    >(
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
                  child:
                      BlocBuilder<
                        GuestPurchasePlanReceiptBloc,
                        GuestPurchasePlanReceiptState
                      >(
                        builder: (context, state) {
                          final data = state.data;
                          if (data == null) return const SizedBox.shrink();

                          void onBackHome() {
                            if (AppSession.appRoute == 'prepaidPlan' ||
                                AppSession.appRoute == 'addOnsPrepaid') {
                              context.go(AppRoutes.home);
                              AppSession.resetAppRoute();
                            } else {
                              context.go(AppRoutes.logIn);
                            }
                          }

                          if (isPaymentFailed) {
                            return ReceiptFailureCard(
                              data: data,
                              onBackHome: onBackHome,
                              pageBackground: GuestPurchasePlanReceiptTheme
                                  .circleBackground,
                            );
                          }

                          return DefaultReceiptSuccessCard(
                            data: data,
                            onBackHome: onBackHome,
                            pageBackground:
                                GuestPurchasePlanReceiptTheme.circleBackground,
                            statusMessage: statusMessage,
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
