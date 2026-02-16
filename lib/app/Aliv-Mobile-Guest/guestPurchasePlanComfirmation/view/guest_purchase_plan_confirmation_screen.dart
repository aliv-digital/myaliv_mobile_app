import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../bloc/guest_purchase_plan_confirmation_bloc.dart';
import '../bloc/guest_purchase_plan_confirmation_event.dart';
import '../bloc/guest_purchase_plan_confirmation_state.dart';
import '../repository/guest_purchase_plan_confirmation_repository.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';
import '../widgets/purchase_summary_card.dart';
import '../widgets/terms_notice.dart';

class GuestPurchasePlanConfirmationScreen extends StatelessWidget {
  const GuestPurchasePlanConfirmationScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => GuestPurchasePlanConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPurchasePlanConfirmationBloc(
          repository: ctx.read<GuestPurchasePlanConfirmationRepository>(),
        )..add(GuestPurchasePlanConfirmationStarted(phoneNumber)),
        child: const _GuestPurchasePlanConfirmationView(),
      ),
    );
  }
}

class _GuestPurchasePlanConfirmationView extends StatelessWidget {
  const _GuestPurchasePlanConfirmationView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestPurchasePlanConfirmationBloc,
        GuestPurchasePlanConfirmationState>(
      listenWhen: (p, c) =>
          p.openTermsRequestId != c.openTermsRequestId ||
          p.payNowRequestId != c.payNowRequestId,
      listener: (context, state) {
        if (state.openTermsRequestId > 0) {
          // Future: open terms page / bottom sheet
          // ignore: avoid_print
          print('Open Terms & Conditions');
        }

        if (state.payNowRequestId > 0) {
          // Future: start payment flow
          // ignore: avoid_print
          print('Pay Now pressed');
        }
      },
      child: Scaffold(
        backgroundColor: GuestPurchasePlanConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar: BlocBuilder<GuestPurchasePlanConfirmationBloc,
            GuestPurchasePlanConfirmationState>(
          builder: (context, state) {
            if (state.status != GuestPurchasePlanConfirmationStatus.ready ||
                state.data == null) {
              return const SizedBox.shrink();
            }

            final total = state.data!.totals.total;

            return DefaultBottomPayBar(
              isVatExclusive: true,
              onPayNow: () =>
                  context.read<GuestPurchasePlanConfirmationBloc>().add(
                        const GuestPurchasePlanConfirmationPayNowPressed(),
                      ),
              amountText: '\$ 75.00'//total.toString(),
            );
          },
        ),

        body: SafeArea(
          child: BlocBuilder<GuestPurchasePlanConfirmationBloc,
              GuestPurchasePlanConfirmationState>(
            builder: (context, state) {
              final data = state.data;

              return Column(
                children: [
                  /// Top app bar (fixed)
                  DefaultAppBar(
                    title: 'confirmation and payment',
                    onBack: () => Navigator.of(context).maybePop(),
                    showBackArrow: true,
                    backgroundColor: GuestPurchasePlanConfirmationTheme.purple,
                  ),

                  /// Scrollable body (Slivers)
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: data == null
                            ? const SizedBox.shrink()
                            : CustomScrollView(
                                slivers: [
                                  /// Purchase summary card (starts right after app bar)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          29, 17, 29, 0),
                                      child: PurchaseSummaryCard(
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<
                                                GuestPurchasePlanConfirmationBloc>()
                                            .add(
                                                GuestPurchasePlanConfirmationRemoveItemPressed(
                                                    id)),
                                      ),
                                    ),
                                  ),

                                  /// Terms notice (your exact padding)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        GuestPurchasePlanConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        GuestPurchasePlanConfirmationTheme
                                            .termsNoticeTopSpacing,
                                        GuestPurchasePlanConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        GuestPurchasePlanConfirmationTheme
                                            .termsNoticeBottomSpacing,
                                      ),
                                      child: TermsNotice(
                                        isChecked: state.isTermsChecked,
                                        onToggleChecked: () => context
                                            .read<
                                                GuestPurchasePlanConfirmationBloc>()
                                            .add(
                                              GuestPurchasePlanConfirmationTermsCheckboxToggled(
                                                !state.isTermsChecked,
                                              ),
                                            ),
                                        onTermsTap: () => context
                                            .read<
                                                GuestPurchasePlanConfirmationBloc>()
                                            .add(
                                                const GuestPurchasePlanConfirmationTermsPressed()),
                                      ),
                                    ),
                                  ),

                                  /// Payment breakdown card
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          29, 0, 29, 0
                                      ),
                                      child: CustomPaymentBreakDownCard(
                                        backgroundColor: HexColor.fromHex('#645D9C'),
                                        items: <CustomPaymentBreakdownLineItem>[
                                          CustomPaymentBreakdownLineItem(
                                            label: 'sub total',
                                            value: '\$ 75.00',
                                               // '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'vat',
                                            value:
                                                '\$ ${data.totals.vat.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'total',
                                            value: '\$ 75.00',
                                            //    '\$ ${data.totals.total.toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// Small bottom spacing (bottomNavigationBar already fixed)
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 24),
                                  ),
                                ],
                              ),
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
