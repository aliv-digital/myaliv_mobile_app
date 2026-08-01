import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/bloc/home_plan_purchase_receipt_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/repository/home_plan_purchase_receipt_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_card_on_receipt_section.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../core/utils/app_session.dart';
import '../bloc/home_plan_purchase_receipt_event.dart';
import '../bloc/home_plan_purchase_receipt_state.dart';
import '../theme/home_plan_purchase_receipt_theme.dart';
import '../widgets/home_plan_purchase_receipt_payment_failure.dart';
import '../widgets/home_plan_purchase_receipt_success_card.dart';

class HomePlanPurchaseReceiptScreen extends StatelessWidget {
  const HomePlanPurchaseReceiptScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
    required this.dateText,
    required this.timeText,
    this.paymentMethod = 'credit card',
    this.statusMessage = 'It will take a few moments for the top-up to appear on the account. ',
    this.leftType = 'service',
    this.rightType = 'REV',
    this.details,
    this.cardToSave,
    this.isPaymentFailed = false,
  });

  final String phoneNumber;
  final double amount;
  final String dateText;
  final String timeText;
  final String paymentMethod;
  final String statusMessage;
  final String leftType;
  final String rightType;
  final List<HomePlanPurchaseReceiptDetailItem>? details;

  /// New-card details captured during payment. When present, the save-card
  /// button is shown; when null (wallet / saved-card payments) the button
  /// hides itself.
  final NewCardDetails? cardToSave;

  /// When true the failure ticket is shown instead of the success card.
  /// The bloc is not created in this case.
  final bool isPaymentFailed;

  @override
  Widget build(BuildContext context) {
    if (isPaymentFailed) {
      return _PaymentFailedReceiptView(phoneNumber: phoneNumber);
    }

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
          cardToSave: cardToSave,
        ),
      ),
    );
  }
}

class _HomePlanPurchaseReceiptView extends StatefulWidget {
  const _HomePlanPurchaseReceiptView({
    required this.statusMessage,
    required this.cardToSave,
  });

  final String statusMessage;
  final NewCardDetails? cardToSave;

  @override
  State<_HomePlanPurchaseReceiptView> createState() =>
      _HomePlanPurchaseReceiptViewState();
}

class _HomePlanPurchaseReceiptViewState
    extends State<_HomePlanPurchaseReceiptView> {
  static const _bg = Color(0xFFF1F2FA);

  @override
  void initState() {
    super.initState();
    // After purchase the backend needs a few seconds to process the plan
    // change before /bundles reflects the new state.  We capture PlansCubit
    // in the first frame (before any navigation could dispose this widget)
    // and fire a forced refresh after the delay — so it runs even if the
    // user has already tapped "Back Home" before the 3 seconds are up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<PlansCubit>();
      Future.delayed(const Duration(seconds: 3), () {
        // Only /bundles is refreshed — /available-plans is unaffected by a purchase.
        if (!cubit.isClosed) cubit.refreshBundlesOnly();
      });
    });
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
                        saveCardSection: SaveCardOnReceiptSection(
                          details: widget.cardToSave,
                        ),
                        pageBackground:
                            HomePlanPurchaseReceiptTheme.circleBackground,
                        statusMessage: widget.statusMessage,
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

/// Minimal receipt screen shown when [HomePlanPurchaseReceiptScreen.isPaymentFailed]
/// is true. No bloc needed — the failure ticket is stateless.
class _PaymentFailedReceiptView extends StatelessWidget {
  const _PaymentFailedReceiptView({required this.phoneNumber});

  final String phoneNumber;

  static const _bg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 29),
                child: HomePlanPurchaseReceiptPaymentFailedTicket(
                  onPressed: () {
                    AppSession.resetAppRoute();
                    context.go(AppRoutes.home);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
