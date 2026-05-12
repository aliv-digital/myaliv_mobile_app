import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../bloc/home_plan_confirmation_bloc.dart';
import '../bloc/home_plan_confirmation_event.dart';
import '../bloc/home_plan_confirmation_state.dart';
import '../models/home_plan_confirmation_models.dart';
import '../repository/home_plan_confirmation_repository.dart';
import '../theme/home_plan_confirmation_theme.dart';
import '../widgets/purchase_summary_card.dart';
import '../widgets/terms_notice.dart';

class HomePlanConfirmationScreen extends StatelessWidget {
  const HomePlanConfirmationScreen({super.key, required this.args});

  final HomePlanConfirmationRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => HomePlanConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => HomePlanConfirmationBloc(
          repository: ctx.read<HomePlanConfirmationRepository>(),
        )..add(HomePlanConfirmationStarted(args)),
        child: const _HomePlanConfirmationView(),
      ),
    );
  }
}

class _HomePlanConfirmationView extends StatelessWidget {
  const _HomePlanConfirmationView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePlanConfirmationBloc, HomePlanConfirmationState>(
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
        backgroundColor: HomePlanConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar:
            BlocBuilder<HomePlanConfirmationBloc, HomePlanConfirmationState>(
          builder: (context, state) {
            if (state.status != HomePlanConfirmationStatus.ready ||
                state.data == null) {
              return const SizedBox.shrink();
            }

            return DefaultBottomPayBar(
              buttonText: 'continue',
              isVatExclusive: true,
              isButtonEnabled: state.isTermsChecked,
              buttonColor: const Color(0xFF645D9C),
              onPayNow: () {
                context.read<HomePlanConfirmationBloc>().add(
                      const HomePlanConfirmationPayNowPressed(),
                    );
                context.push(
                  AppRoutes.homePlansPaymentMethodScreen,
                  extra: HomePlansPaymentMethodRouteArgs(
                    amount: state.data!.totals.total,
                    vatNote: state.data!.totals.vat > 0
                        ? 'vat included'
                        : 'no vat applied',
                  ),
                );
              },
              amountText: '\$ ${state.data!.totals.total.toStringAsFixed(2)}',
            );
          },
        ),

        body: SafeArea(
          child:
              BlocBuilder<HomePlanConfirmationBloc, HomePlanConfirmationState>(
            builder: (context, state) {
              final data = state.data;

              return Column(
                children: [
                  /// Top app bar (fixed)
                  DefaultAppBar(
                    showHome: true,
                    onHomeTap: () {
                      context.go(AppRoutes.home);
                    },
                    title: 'confirmation and payment',
                    onBack: () {
                      context.pop();
                    },
                    showBackArrow: true,
                    backgroundColor: HomePlanConfirmationTheme.purple,
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
                                        HomePlanConfirmationTheme
                                            .contentHorizontalPadding,
                                        HomePlanConfirmationTheme
                                            .purchaseSummaryCardTopSpacing,
                                        HomePlanConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                      ),
                                      child: PurchaseSummaryCard(
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<HomePlanConfirmationBloc>()
                                            .add(
                                              HomePlanConfirmationRemoveItemPressed(
                                                id,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),

                                  /// Terms notice (your exact padding)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        HomePlanConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        HomePlanConfirmationTheme
                                            .termsNoticeTopSpacing,
                                        HomePlanConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        HomePlanConfirmationTheme
                                            .termsNoticeBottomSpacing,
                                      ),
                                      child: TermsNotice(
                                        isChecked: state.isTermsChecked,
                                        onToggleChecked: () => context
                                            .read<HomePlanConfirmationBloc>()
                                            .add(
                                              HomePlanConfirmationTermsCheckboxToggled(
                                                !state.isTermsChecked,
                                              ),
                                            ),
                                        onTermsTap: () async {
                                          debugPrint("--");
                                          await showTermsAndConditionsModal(
                                            context,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  /// Payment breakdown card
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        HomePlanConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                        HomePlanConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                      ),
                                      child: CustomPaymentBreakDownCard(
                                        backgroundColor:
                                            HexColor.fromHex('#645D9C'),
                                        input:
                                            const CustomPaymentBreakdownInputConfig(
                                          value: '',
                                          hintText: 'promo code',
                                          actionText: 'apply',
                                        ),
                                        items: <CustomPaymentBreakdownLineItem>[
                                          CustomPaymentBreakdownLineItem(
                                            label: 'subtotal',
                                            value:
                                                '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'vat',
                                            // Repository combines primary-plan VAT
                                            // and selected add-on VAT into this value.
                                            value:
                                                '\$ ${data.totals.vat.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'total',
                                            value:
                                                '\$ ${data.totals.total.toStringAsFixed(2)}',
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
