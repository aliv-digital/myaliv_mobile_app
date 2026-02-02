import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/make_payment_confirmation_postpaid_bloc.dart';
import '../bloc/make_payment_confirmation_postpaid_event.dart';
import '../bloc/make_payment_confirmation_postpaid_state.dart';
import '../repository/make_payment_confirmation_postpaid_repository_impl.dart';
import '../theme/make_payment_confirmation_postpaid_theme.dart';
import '../widgets/mp_bottom_bar.dart';
import '../widgets/mp_header_card.dart';
import '../../../../../../resources/widgets/default_payment_break_down_card.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../router/app_routes.dart';

class MakePaymentConfirmationPostPaidScreen extends StatelessWidget {
  const MakePaymentConfirmationPostPaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MakePaymentConfirmationPostPaidBloc(
        repository: MakePaymentConfirmationPostPaidRepositoryImpl(),
      )..add(const MakePaymentConfirmationPostPaidStarted()),
      child: const _MakePaymentConfirmationPostPaidView(),
    );
  }
}

class _MakePaymentConfirmationPostPaidView extends StatelessWidget {
  const _MakePaymentConfirmationPostPaidView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      MakePaymentConfirmationPostPaidBloc,
      MakePaymentConfirmationPostPaidState
    >(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget == MakePaymentConfirmationNavTarget.next) {
          context.read<MakePaymentConfirmationPostPaidBloc>().add(
            const MakePaymentNavConsumed(),
          );
        }
      },
      builder: (context, state) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: MakePaymentConfirmationPostPaidTheme.bg,
            bottomNavigationBar: MpBottomBar(
              amountText: state.bottomAmount,
              subtitle: state.bottomSubtitle,
              onContinue: () {
                context.read<MakePaymentConfirmationPostPaidBloc>().add(
                  const MakePaymentContinuePressed(),
                );
                context.push(AppRoutes.makePaymentPostpaidScreen);
              },
            ),
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: MakePaymentConfirmationPostPaidTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: state.title,
                      height: MakePaymentConfirmationPostPaidTheme.appBarHeight,
                      backgroundColor:
                          MakePaymentConfirmationPostPaidTheme.appBarBg,
                      showBackArrow: true,
                      showHome: true,
                      onHomeTap: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(29, 24, 29, 22),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MpHeaderCard(
                                customerName: state.customerName,
                                accountNumber: state.accountNumber,
                                headerLabel: state.headerLabel,
                                amountText: state.amountPill,
                              ),
                              const SizedBox(height: 14),
                              DefaultPaymentBreakDownCard(
                                backgroundColor:
                                    MakePaymentConfirmationPostPaidTheme
                                        .receiptBg,
                                targetScallopCount: 12,
                                input: PaymentBreakdownInputConfig(
                                  value: state.promoCode,
                                  enabled: true,
                                  hintText: 'promo code',
                                  actionText: 'apply',
                                  onChanged: (value) {
                                    context
                                        .read<
                                          MakePaymentConfirmationPostPaidBloc
                                        >()
                                        .add(
                                          MakePaymentPromoCodeChanged(value),
                                        );
                                  },
                                  onActionTap: state.canApplyPromo
                                      ? () {
                                          context
                                              .read<
                                                MakePaymentConfirmationPostPaidBloc
                                              >()
                                              .add(
                                                const MakePaymentPromoApplyPressed(),
                                              );
                                        }
                                      : null,
                                ),
                                items: [
                                  PaymentBreakdownLineItem(
                                    label: 'sub total',
                                    value: state.subtotal,
                                  ),
                                  PaymentBreakdownLineItem(
                                    label: 'vat',
                                    value: state.vat,
                                  ),
                                  PaymentBreakdownLineItem(
                                    label: 'total',
                                    value: state.total,
                                    isEmphasized: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 90),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
