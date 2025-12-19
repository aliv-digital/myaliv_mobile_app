import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';

import '../bloc/confirm_topup_bloc.dart';
import '../bloc/confirm_topup_event.dart';
import '../bloc/confirm_topup_state.dart';
import '../repository/confirm_topup_repository.dart';
import '../widgets/bottom_pay_bar.dart';
import '../widgets/payment_breakdown_card.dart';
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

  static const _purple = Color(0xFF655C9A);
  static const _bg = Color(0xFFF1F2FA);

  void _openTerms(BuildContext context) {
    // TODO: open terms page / modal / webview
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
      listenWhen: (prev, curr) =>
      prev.status != curr.status || prev.termsRequestId != curr.termsRequestId,
      listener: (context, state) {
        if (state.status == GuestConfirmTopUpStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful')),
          );
        }

        if (state.status == GuestConfirmTopUpStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Payment failed')),
          );
        }

        if (state.termsRequestId != 0) {
          _openTerms(context);
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        bottomNavigationBar: BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
          builder: (context, state) {
            return BottomPayBar(
              amountText: '\$ ${state.total.toStringAsFixed(2)}',
              isLoading: state.status == GuestConfirmTopUpStatus.loading,
              onPayNow: () => context.read<GuestConfirmTopUpBloc>().add(
                const GuestConfirmTopUpPayNowPressed(),
              ),
            );
          },
        ),
        body: SafeArea(
            child: CustomScrollView(
          slivers: [

            SliverToBoxAdapter(
              child: DefaultAppBar(title: 'confirmation and payment', onBack: (){}),
            ),
            // 1) Top card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 29,right:29,top: 31),
                child: BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
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

            // spacing
            //const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // 2) Terms text
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 29,right: 29,top: 17,bottom: 17),
                child: BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                  builder: (context, state) {
                    return TermsAndConditionsText(
                      onTapTerms: () => context.read<GuestConfirmTopUpBloc>().add(
                        const GuestConfirmTopUpTermsPressed(),
                      ),
                    );
                  },
                ),
              ),
            ),

            //const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // 3) Payment breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 29,right: 29),
                child: BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                  buildWhen: (p, c) =>
                  p.subTotal != c.subTotal || p.vat != c.vat || p.total != c.total,
                  builder: (context, state) {
                    return PaymentBreakdownCard(
                      subTotal: state.subTotal,
                      vat: state.vat,
                      total: state.total,
                    );
                  },
                ),
              ),
            ),

            // bottom spacing যাতে bottom bar এর সাথে collide না করে
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        )
        ),
      ),
    );
  }
}
