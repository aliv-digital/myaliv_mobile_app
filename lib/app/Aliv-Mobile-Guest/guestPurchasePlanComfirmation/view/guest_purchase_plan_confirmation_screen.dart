import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../Aliv-Mobile/revBillPay/revConfirmation/prepaid/theme/rev_confirmation_prepaid_theme.dart';
import '../bloc/guest_purchase_plan_confirmation_bloc.dart';
import '../bloc/guest_purchase_plan_confirmation_event.dart';
import '../bloc/guest_purchase_plan_confirmation_state.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';
import '../repository/guest_purchase_plan_confirmation_repository.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';
import '../widgets/purchase_summary_card.dart';
import '../widgets/terms_notice.dart';

class GuestPurchasePlanConfirmationScreen extends StatelessWidget {
  const GuestPurchasePlanConfirmationScreen({
    super.key,
    required this.args,
  });

  final GuestPurchasePlanConfirmationRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => GuestPurchasePlanConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPurchasePlanConfirmationBloc(
          repository: ctx.read<GuestPurchasePlanConfirmationRepository>(),
        )..add(GuestPurchasePlanConfirmationStarted(args)),
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
      listenWhen: (previous, current) =>
          previous.openTermsRequestId != current.openTermsRequestId ||
          previous.payNowRequestId != current.payNowRequestId,
      listener: (context, state) {
        if (state.openTermsRequestId > 0) {
          debugPrint('Open Terms & Conditions');
        }

        if (state.payNowRequestId > 0) {
          debugPrint('Pay Now pressed');
        }
      },
      child: Scaffold(
        backgroundColor: GuestPurchasePlanConfirmationTheme.bg,
        bottomNavigationBar: BlocBuilder<GuestPurchasePlanConfirmationBloc,
            GuestPurchasePlanConfirmationState>(
          builder: (context, state) {
            if (state.status != GuestPurchasePlanConfirmationStatus.ready ||
                state.data == null) {
              return const SizedBox.shrink();
            }

            return DefaultBottomPayBar(
              isVatExclusive: true,
              isButtonEnabled: state.isTermsChecked,
              buttonColor: const Color(0xFF645D9C),
              onPayNow: () {
                final data = state.data!;
                final primaryPlanName = data.items
                    .firstWhere(
                      (item) => item.type == PurchaseLineType.primaryPlan,
                      orElse: () => const PurchaseLineItem(
                        id: '',
                        type: PurchaseLineType.primaryPlan,
                        label: '',
                        title: '',
                        subtitle: '',
                        price: 0,
                      ),
                    )
                    .title;
                final addOnNames = data.items
                    .where((item) => item.type == PurchaseLineType.addOn)
                    .map((item) => item.title)
                    .toList(growable: false);
                final now = DateTime.now();

                context.push(
                  AppRoutes.guestPurchasePlanReceipt,
                  extra: <String, Object?>{
                    'phoneNumber': data.phoneNumber,
                    'amount': data.totals.total,
                    'planName': primaryPlanName.isEmpty ? null : primaryPlanName,
                    'addOnNames': addOnNames,
                    'dateText': DateFormat('MMM d, yyyy').format(now),
                    'timeText':
                        DateFormat('h:mm a').format(now).toLowerCase(),
                    'emailAddress': 'guest',
                  },
                );
              },
              amountText: '\$ ${state.data!.totals.total.toStringAsFixed(2)}',
            );
          },
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<GuestPurchasePlanConfirmationBloc,
              GuestPurchasePlanConfirmationState>(
            builder: (context, state) {
              final data = state.data;

              return Column(
                children: [
                  DefaultAppBar(
                    height: 63,
                    title: 'confirmation and payment',
                    onBack: () => Navigator.of(context).maybePop(),
                    onHomeTap: () => context.go(AppRoutes.logIn),
                    showBackArrow: true,
                    showHome: false,
                    backgroundColor: GuestPurchasePlanConfirmationTheme.purple,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: data == null
                            ? const SizedBox.shrink()
                            : CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        29,
                                        17,
                                        29,
                                        0,
                                      ),
                                      child: PurchaseSummaryCard(
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<
                                                GuestPurchasePlanConfirmationBloc>()
                                            .add(
                                              GuestPurchasePlanConfirmationRemoveItemPressed(
                                                id,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
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
                                        onTermsTap: () async {
                                          await showTermsAndConditionsModal(
                                            context,
                                            badgeSize: 48,
                                            badgeInnerSize: 34,
                                            badgeCoreSize: 24,
                                            badgeIconWidth: 16,
                                            badgeIconHeight: 16,
                                            closeButtonSize: 30,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        29,
                                        0,
                                        29,
                                        0,
                                      ),
                                      child: CustomPaymentBreakDownCard(
                                        backgroundColor:
                                            RevConfirmationPrepaidTheme
                                                .receiptBg,
                                        scallopCount: 12,
                                        input: null,
                                        items: <CustomPaymentBreakdownLineItem>[
                                          CustomPaymentBreakdownLineItem(
                                            label: 'sub total',
                                            value:
                                                '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'vat',
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
