import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/widgets/payment_breakdown_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';

import '../bloc/guest_pay_bill_confirm_bloc.dart';
import '../bloc/guest_pay_bill_confirm_event.dart';
import '../bloc/guest_pay_bill_confirm_state.dart';
import '../model/guest_pay_bill_confirm_models.dart';
import '../theme/guest_pay_bill_confirm_theme.dart';
import '../widgets/guest_pay_bill_confirm_bottom_bar.dart';
import '../widgets/guest_pay_bill_confirm_header_card.dart';
import '../widgets/guest_pay_bill_confirm_terms_row.dart';

class GuestPayBillConfirmScreen extends StatelessWidget {
  final GuestPayBillConfirmArgs args;

  const GuestPayBillConfirmScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuestPayBillConfirmBloc(args: args)
        ..add(const GuestPayBillConfirmStarted()),
      child: const _GuestPayBillConfirmView(),
    );
  }
}

class _GuestPayBillConfirmView extends StatelessWidget {
  const _GuestPayBillConfirmView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestPayBillConfirmBloc, GuestPayBillConfirmState>(
      listenWhen: (p, c) =>
      p.errorMessage != c.errorMessage || p.payStatus != c.payStatus,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        if (state.payStatus == GuestPayBillConfirmPayStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful')),
          );
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: GuestPayBillConfirmTheme.pageBg,
        bottomNavigationBar:
        BlocBuilder<GuestPayBillConfirmBloc, GuestPayBillConfirmState>(
          builder: (context, state) {
            return GuestPayBillConfirmBottomBar(
              amount: state.total,
              loading: state.payStatus == GuestPayBillConfirmPayStatus.loading,
              onPayNow: () {
                context
                    .read<GuestPayBillConfirmBloc>()
                    .add(const GuestPayBillConfirmPayNowPressed());
              },
            );
          },
        ),
        body: SafeArea(
          child: BlocBuilder<GuestPayBillConfirmBloc, GuestPayBillConfirmState>(
            builder: (context, state) {
              if (state.loadStatus == GuestPayBillConfirmLoadStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return CustomScrollView(
                slivers: [
                  // AppBar: no padding here
                  SliverToBoxAdapter(
                    child: DefaultAppBar(
                      title: 'confirmation and payment',
                      onBack: () {
                        Navigator.of(context).maybePop();
                      },
                    ),
                  ),

                  //  Everything below AppBar will have padding (as you wanted)
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 29,
                      right: 29,
                      top: 21,
                      // bottom not needed because bottom bar exists
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          GuestPayBillConfirmHeaderCard(
                            serviceName: state.args.serviceName,
                            identifierLabel: state.args.identifierLabel,
                            identifierValue: state.args.identifierValue,
                            amount: state.args.amount,
                          ),

                          const SizedBox(height: 16),

                          GuestPayBillConfirmTermsRow(
                            onTapTerms: () {
                              // TODO: open Terms page / webview / route
                              // Example:
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => TermsScreen()));
                            },
                          ),

                          const SizedBox(height: 16),

                          PaymentBreakdownCard(
                            subTotal: state.subTotal,
                            vat: state.vat,
                            total: state.total,
                          ),

                          //  Optional bottom spacing so last card doesn't feel tight
                          const SizedBox(height: 18),
                        ],
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
}
