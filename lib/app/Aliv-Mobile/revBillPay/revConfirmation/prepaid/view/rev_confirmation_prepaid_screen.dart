import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/custom_payment_break_down_card.dart';
import '../../../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../../../router/app_routes.dart';
import '../bloc/rev_confirmation_prepaid_bloc.dart';
import '../bloc/rev_confirmation_prepaid_event.dart';
import '../bloc/rev_confirmation_prepaid_state.dart';
import '../repository/rev_confirmation_prepaid_repository_impl.dart';
import '../theme/rev_confirmation_prepaid_theme.dart';
import '../widgets/rev_confirmation_header_card.dart';
import '../widgets/rev_terms_text.dart'; // ✅ NEW (replace rev_terms_text.dart)

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
    return BlocConsumer<
      RevConfirmationPrepaidBloc,
      RevConfirmationPrepaidState
    >(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget != RevConfirmNavTarget.none) {
          context.read<RevConfirmationPrepaidBloc>().add(
            const RevNavConsumed(),
          );
        }

        //  optional: show error if user presses continue without accepting terms
        if (state.showTermsError == true) {
          AppToast.show(
              message: 'Please accept Terms & Conditions',
              type: ToastType.error
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text()),
          // );
        }
      },
      builder: (context, state) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: RevConfirmationPrepaidTheme.bg,
            bottomNavigationBar: DefaultBottomPayBar(
              isVatExclusive: true,
              amountText: state.totalText,
              buttonText: 'continue',
              onPayNow: () {
                context.read<RevConfirmationPrepaidBloc>().add(
                  const RevContinuePressed(),
                );
                context.push(AppRoutes.revPaymentMethodPrepaidScreen);
              },
            ),
            body: Column(
              children: [
                DefaultAppBar(
                  title: state.title,
                  height: RevConfirmationPrepaidTheme.appBarHeight,
                  backgroundColor: RevConfirmationPrepaidTheme.appBarBg,
                  showBackArrow: true,
                  showHome: true,
                  onHomeTap: () => context.go(AppRoutes.home),
                ),

                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          RevConfirmationPrepaidTheme.contentHorizontalPadding,
                          RevConfirmationPrepaidTheme.contentTopPadding,
                          RevConfirmationPrepaidTheme.contentHorizontalPadding,
                          RevConfirmationPrepaidTheme.contentBottomPadding,
                        ),
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
                              const SizedBox(
                                height: RevConfirmationPrepaidTheme.sectionGap,
                              ),

                              // ✅ NEW: checkbox + link
                              RevTermsCheckbox(
                                value: state.termsAccepted,
                                onChanged: (v) => context
                                    .read<RevConfirmationPrepaidBloc>()
                                    .add(RevTermsToggled(v)),
                                onTermsTap: () async {
                                  await showTermsAndConditionsModal(context);
                                },
                              ),

                              const SizedBox(
                                height: RevConfirmationPrepaidTheme.sectionGap,
                              ),

                              CustomPaymentBreakDownCard(
                                backgroundColor:
                                    RevConfirmationPrepaidTheme.receiptBg,
                                scallopCount: 12,
                                input: CustomPaymentBreakdownInputConfig(
                                  value: state.promoCode,
                                  enabled: true,
                                  hintText: 'promo code',
                                  actionText: 'apply',
                                  onChanged: (v) {
                                    context
                                        .read<RevConfirmationPrepaidBloc>()
                                        .add(RevPromoCodeChanged(v));
                                  },
                                  onActionTap: () {
                                    context
                                        .read<RevConfirmationPrepaidBloc>()
                                        .add(const RevPromoApplyPressed());
                                  },
                                ),
                                items: [
                                  CustomPaymentBreakdownLineItem(
                                    label: 'sub total',
                                    value: state.subtotalText,
                                  ),
                                  CustomPaymentBreakdownLineItem(
                                    label: 'vat',
                                    value: state.vatText,
                                  ),
                                  CustomPaymentBreakdownLineItem(
                                    label: 'total',
                                    value: state.totalText,
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
