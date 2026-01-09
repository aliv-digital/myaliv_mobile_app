import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/guest_purchase_plan_confirmation_bloc.dart';
import '../bloc/guest_purchase_plan_confirmation_event.dart';
import '../bloc/guest_purchase_plan_confirmation_state.dart';
import '../repository/guest_purchase_plan_confirmation_repository.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';
import '../widgets/purchase_summary_card.dart';
import '../widgets/terms_notice.dart';
import '../widgets/total_ticket_card.dart';
import '../widgets/bottom_pay_bar.dart';

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
      listenWhen: (p, c) => p.openTermsRequestId != c.openTermsRequestId || p.payNowRequestId != c.payNowRequestId,
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
                            /// IMPORTANT:
                            /// - list/summary starts immediately after app bar
                            /// - No extra top padding except a small one for breathing space
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                                child: PurchaseSummaryCard(
                                  data: data,
                                  onRemoveItem: (id) => context
                                      .read<GuestPurchasePlanConfirmationBloc>()
                                      .add(GuestPurchasePlanConfirmationRemoveItemPressed(id)),
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                                child: TermsNotice(
                                  onTermsTap: () => context
                                      .read<GuestPurchasePlanConfirmationBloc>()
                                      .add(const GuestPurchasePlanConfirmationTermsPressed()),
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                                child: TotalTicketCard(totals: data.totals),
                              ),
                            ),

                            /// Bottom spacing so last card doesn't hide behind bottom bar
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 110, // enough space for BottomPayBar overlay
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Bottom pay bar (fixed)
                  if (data != null)
                    BottomPayBar(
                      total: data.totals.total,
                      onPayNow: () => context
                          .read<GuestPurchasePlanConfirmationBloc>()
                          .add(const GuestPurchasePlanConfirmationPayNowPressed()),
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
