import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/bloc/home_plan_purchase_receipt_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/repository/home_plan_purchase_receipt_repository.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../core/utils/app_session.dart';
import '../bloc/home_plan_purchase_receipt_event.dart';
import '../bloc/home_plan_purchase_receipt_state.dart';
import '../theme/home_plan_purchase_receipt_theme.dart';
import '../widgets/home_plan_purchase_receipt_save_card_bottom_sheet.dart';
import '../widgets/home_plan_purchase_receipt_success_card.dart';

class HomePlanPurchaseReceiptScreen extends StatelessWidget {
  const HomePlanPurchaseReceiptScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
    required this.dateText,
    required this.timeText,
    this.hideSaveCreditCard = false,
    this.paymentMethod = 'credit card',
    this.statusMessage = 'It will take a few moments for the top-up to appear on the account. ',
    this.leftType = 'service',
    this.rightType = 'REV',
    this.details,
  });

  final String phoneNumber;
  final double amount;
  final String dateText;
  final String timeText;
  final bool hideSaveCreditCard;
  final String paymentMethod;
  final String statusMessage;
  final String leftType;
  final String rightType;
  final List<HomePlanPurchaseReceiptDetailItem>? details;

  @override
  Widget build(BuildContext context) {
    final displayPaymentMethod =
        AppSession.appRoute == 'prepaidPlanPurchase' ? 'wallet' : paymentMethod;

    /// Dynamic details list. Prefer values passed through route `extra`; keep
    /// the old placeholder rows only for legacy callers that do not pass data.
    final receiptDetails = details ?? <HomePlanPurchaseReceiptDetailItem>[
          const HomePlanPurchaseReceiptDetailItem(
            label: 'plan',
            value: 'liberty70',
            valueBold: false,
          ),
          const HomePlanPurchaseReceiptDetailItem(
            label: 'add-on',
            value: 'liberty data 1',
          ),
          HomePlanPurchaseReceiptDetailItem(label: 'date', value: dateText),
          HomePlanPurchaseReceiptDetailItem(label: 'time', value: timeText),
          HomePlanPurchaseReceiptDetailItem(
            label: 'phone no.',
            value: phoneNumber,
          ),
          const HomePlanPurchaseReceiptDetailItem(
            label: 'email address',
            value: 'jade123@hotmail.com',
          ),
          HomePlanPurchaseReceiptDetailItem(
            label: 'payment method',
            value: displayPaymentMethod,
          ),
        ];

    final receiptData = HomePlanPurchaseReceiptData(
      leftType: leftType,
      rightType: rightType,
      dateText: dateText,
      timeText: timeText,
      phoneNumber: phoneNumber,
      paymentMethod: displayPaymentMethod,
      amount: amount,
      details: receiptDetails,
    );

    return RepositoryProvider(
      create: (_) => HomePlanPurchaseReceiptRepository(),
      child: BlocProvider(
        create: (ctx) => HomePlanPurchaseReceiptBloc(
          repository: ctx.read<HomePlanPurchaseReceiptRepository>(),
        )..add(HomePlanPurchaseReceiptStarted(receiptData)),
        child: _HomePlanPurchaseReceiptView(
          statusMessage: statusMessage,
          hideSaveCreditCard: hideSaveCreditCard,
        ),
      ),
    );
  }
}

class _HomePlanPurchaseReceiptView extends StatelessWidget {
  const _HomePlanPurchaseReceiptView({
    required this.statusMessage,
    required this.hideSaveCreditCard,
  });

  static const _bg = Color(0xFFF1F2FA);
  final String statusMessage;
  final bool hideSaveCreditCard;

  void _showSaveCardBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return const HomePlanPurchaseReceiptSaveCardBottomSheet(
          cardMask: '*1234',
          initialMonth: 'January',
          initialYear: '2025',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePlanPurchaseReceiptBloc, HomePlanPurchaseReceiptState>(
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
                  child: BlocBuilder<HomePlanPurchaseReceiptBloc,
                      HomePlanPurchaseReceiptState>(
                    builder: (context, state) {
                      final data = state.data;
                      if (data == null) return const SizedBox.shrink();

                      return HomePlanPurchaseReceiptSuccessCard(
                        data: data,
                        onBackHome: () {
                          if (AppSession.appRoute == 'prepaidPlan' ||
                              AppSession.appRoute == 'postpaidPlan' ||
                              AppSession.appRoute == 'prepaidPlanPurchase' ||
                              AppSession.appRoute == 'addOnsPrepaid') {
                            context.go(AppRoutes.home);
                            AppSession.resetAppRoute();
                          } else {
                            context.go(AppRoutes.home);
                          }
                        },
                        onSaveCard: () {
                          _showSaveCardBottomSheet(context);
                        },
                        hideSaveCreditCard:
                            AppSession.appRoute == 'prepaidPlanPurchase'
                                ? true
                                : hideSaveCreditCard,
                        pageBackground:
                            HomePlanPurchaseReceiptTheme.circleBackground,
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
              //         child: BlocBuilder<HomePlanPurchaseReceiptBloc, HomePlanPurchaseReceiptState>(
              //           builder: (context, state) {
              //             final data = state.data;
              //             if (data == null) return const SizedBox.shrink();
              //
              //             return HomePlanPurchaseReceiptPaymentFailedTicket(
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
