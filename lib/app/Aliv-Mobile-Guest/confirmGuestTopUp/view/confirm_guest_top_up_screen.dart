import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/confirm_topup_bloc.dart';
import '../bloc/confirm_topup_event.dart';
import '../bloc/confirm_topup_state.dart';
import '../repository/confirm_topup_repository.dart';
import '../theme/theme.dart';
import '../widgets/bottom_pay_bar.dart';
import '../widgets/terms_and_conditions_text.dart';
import '../widgets/topup_summary_card.dart';

class GuestConfirmTopUpScreen extends StatelessWidget {
  const GuestConfirmTopUpScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
  });

  final String phoneNumber;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => GuestConfirmTopUpRepository(),
      child: BlocProvider(
        create: (ctx) => GuestConfirmTopUpBloc(
          repository: ctx.read<GuestConfirmTopUpRepository>(),
        )..add(
            GuestConfirmTopUpStarted(
              phoneNumber: phoneNumber,
              amount: amount,
            ),
          ),
        child: const _GuestConfirmTopUpView(),
      ),
    );
  }
}

class _GuestConfirmTopUpView extends StatelessWidget {
  const _GuestConfirmTopUpView();

  void _openTerms(BuildContext context) {
    // TODO: open terms page / modal / webview
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.termsRequestId != curr.termsRequestId,
      listener: (context, state) {
        if (state.status == GuestConfirmTopUpStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment successful',
                style: TopUpConfirmTheme.snackBarText,
              ),
            ),
          );
        }

        if (state.status == GuestConfirmTopUpStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Payment failed',
                style: TopUpConfirmTheme.snackBarText,
              ),
            ),
          );
        }

        if (state.termsRequestId != 0) {
          _openTerms(context);
        }
      },
      child: Scaffold(
        backgroundColor: TopUpConfirmTheme.screenBackgroundColor,
        bottomNavigationBar:
            BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
          builder: (context, state) {
            return BottomPayBar(
                amountText: '\$ ${state.total.toStringAsFixed(2)}',
                isLoading: state.status == GuestConfirmTopUpStatus.loading,
                onPayNow: () {
                  // context.read<GuestConfirmTopUpBloc>().add(
                  //   const GuestConfirmTopUpPayNowPressed(),
                  // );
                  context.push(AppRoutes.guestTopUpReceipt);
                });
          },
        ),
        body: SafeArea(
            child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DefaultAppBar(
                  backgroundColor: TopUpConfirmTheme.appBarColor,
                  title: 'confirmation and payment',
                  onBack: () {
                    context.pop();
                  }),
            ),
            // 1) Top card
            SliverToBoxAdapter(
              child: Padding(
                padding: TopUpConfirmTheme.summaryWrapperPadding,
                child:
                    BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                  buildWhen: (p, c) =>
                      p.phoneNumber != c.phoneNumber || p.total != c.total,
                  builder: (context, state) {
                    return TopUpSummaryCard(
                      phoneNumber: state.phoneNumber,
                      amountText: '\$ ${state.total.toStringAsFixed(2)}',
                    );
                  },
                ),
              ),
            ),

            // 2) Terms text
            SliverToBoxAdapter(
              child: Padding(
                padding: TopUpConfirmTheme.termsWrapperPadding,
                child:
                    BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                  builder: (context, state) {
                    return TermsAndConditionsText(
                      isChecked: state.isTermsChecked,
                      onToggleChecked: () =>
                          context.read<GuestConfirmTopUpBloc>().add(
                                const GuestConfirmTopUpTermsCheckboxToggled(),
                              ),
                      onTapTerms: () =>
                          context.read<GuestConfirmTopUpBloc>().add(
                                const GuestConfirmTopUpTermsPressed(),
                              ),
                    );
                  },
                ),
              ),
            ),

            // 3) Payment breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding: TopUpConfirmTheme.breakdownWrapperPadding,
                child:
                    BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                  buildWhen: (p, c) =>
                      p.subTotal != c.subTotal ||
                      p.vat != c.vat ||
                      p.total != c.total,
                  builder: (context, state) {
                    // Local card kept for reference:
                    // return PaymentBreakdownCard(
                    //   subTotal: state.subTotal,
                    //   vat: state.vat,
                    //   total: state.total,
                    // );
                    return CustomPaymentBreakDownCard(
                      items: [
                        CustomPaymentBreakdownLineItem(
                          label: 'sub total',
                          value: '\$ ${state.subTotal.toStringAsFixed(2)}',
                        ),
                        CustomPaymentBreakdownLineItem(
                          label: 'vat',
                          value: '\$ ${state.vat.toStringAsFixed(2)}',
                        ),
                        CustomPaymentBreakdownLineItem(
                          label: 'total',
                          value: '\$ ${state.total.toStringAsFixed(2)}',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: TopUpConfirmTheme.bottomScrollSpacing),
            ),
          ],
        )),
      ),
    );
  }
}
