import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/default_payment_break_down_card.dart';
import '../bloc/rev_confirmation_prepaid_bloc.dart';
import '../bloc/rev_confirmation_prepaid_event.dart';
import '../bloc/rev_confirmation_prepaid_state.dart';
import '../repository/rev_confirmation_prepaid_repository_impl.dart';
import '../theme/rev_confirmation_prepaid_theme.dart';
import '../widgets/rev_bottom_bar.dart';
import '../widgets/rev_confirmation_header_card.dart';
import '../widgets/rev_terms_text.dart';

class RevConfirmationPrepaidScreen extends StatelessWidget {
  const RevConfirmationPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RevConfirmationPrepaidBloc(
        repository: RevConfirmationPrepaidRepositoryImpl(),
      )..add(const RevConfirmationStarted()),
      child: const _RevConfirmationPrepaidView(),
    );
  }
}

class _RevConfirmationPrepaidView extends StatelessWidget {
  const _RevConfirmationPrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RevConfirmationPrepaidBloc, RevConfirmationPrepaidState>(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget != RevConfirmNavTarget.none) {
          context.read<RevConfirmationPrepaidBloc>().add(const RevNavConsumed());
        }
      },
      builder: (context, state) {
        return MediaQuery(
          // ✅ Pixel-perfect: disable device font scaling impact
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: RevConfirmationPrepaidTheme.bg,
            bottomNavigationBar: RevBottomBar(
              amountText: state.totalText,
              onContinue: () => context.read<RevConfirmationPrepaidBloc>().add(
                const RevContinuePressed(),
              ),
            ),
            body: Column(
              children: [
                // ✅ SafeArea ONLY for the top system status bar
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: RevConfirmationPrepaidTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: state.title,
                      height: RevConfirmationPrepaidTheme.appBarHeight,
                      backgroundColor: RevConfirmationPrepaidTheme.appBarBg,
                      showBackArrow: true,
                      showHome: true,
                      onHomeTap: () {
                        // hook later
                      },
                    ),
                  ),
                ),

                // ✅ Scrollable body (AppBar stays fixed)
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RevConfirmationHeaderCard(
                                customerName: state.customerName,
                                service: state.service,
                                accountNumber: state.accountNumber,
                                amountText: state.headerAmountPillText,
                              ),
                              const SizedBox(height: 14),
                              const RevTermsText(),
                              const SizedBox(height: 14),

                              // ✅ NEW: shared reusable widget (instead of RevReceiptPanel)
                              DefaultPaymentBreakDownCard(
                                backgroundColor: RevConfirmationPrepaidTheme.receiptBg,
                                targetScallopCount: 12,
                                input: PaymentBreakdownInputConfig(
                                  value: state.promoCode,
                                  enabled: true,//state.canApplyPromo,
                                  hintText: 'promo code',
                                  actionText: 'apply',
                                  onChanged: (v) {
                                    context.read<RevConfirmationPrepaidBloc>().add(RevPromoCodeChanged(v));
                                  },
                                  onActionTap: () {
                                    context.read<RevConfirmationPrepaidBloc>().add(const RevPromoApplyPressed());
                                  },
                                ),
                                items: [
                                  PaymentBreakdownLineItem(
                                    label: 'sub total',
                                    value: state.subtotalText,
                                  ),
                                  PaymentBreakdownLineItem(
                                    label: 'vat',
                                    value: state.vatText,
                                  ),
                                  PaymentBreakdownLineItem(
                                    label: 'total',
                                    value: state.totalText,
                                    isEmphasized: true,
                                  ),
                                ],
                              ),

                              //  exact breathing space above bottom bar
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
