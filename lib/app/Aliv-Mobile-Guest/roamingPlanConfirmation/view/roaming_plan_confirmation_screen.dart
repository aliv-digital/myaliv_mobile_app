import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/models/roaming_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../bloc/roaming_plan_confirmation_bloc.dart';
import '../bloc/roaming_plan_confirmation_event.dart';
import '../bloc/roaming_plan_confirmation_state.dart';
import '../repository/roaming_plan_confirmation_repository.dart';
import '../theme/roaming_plan_confirmation_theme.dart';
import '../widgets/begins_on_card.dart';
import '../widgets/purchase_summary_card.dart';
import '../widgets/terms_notice.dart';

class RoamingPlanConfirmationScreen extends StatelessWidget {
  const RoamingPlanConfirmationScreen({
    super.key,
    required this.phoneNumber,
    this.showDateField = false,
  });

  final String phoneNumber;
  final bool showDateField;

  @override
  Widget build(BuildContext context) {
    debugPrint("showDateField: $showDateField");
    return RepositoryProvider(
      create: (_) => RoamingPlanConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => RoamingPlanConfirmationBloc(
          repository: ctx.read<RoamingPlanConfirmationRepository>(),
        )..add(RoamingPlanConfirmationStarted(phoneNumber)),
        child: _RoamingPlanConfirmationView(showDateField: showDateField),
      ),
    );
  }
}

class _RoamingPlanConfirmationView extends StatelessWidget {
  const _RoamingPlanConfirmationView({
    required this.showDateField,
  });

  final bool showDateField;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoamingPlanConfirmationBloc,
        RoamingPlanConfirmationState>(
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
        backgroundColor: RoamingPlanConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar: BlocBuilder<RoamingPlanConfirmationBloc,
            RoamingPlanConfirmationState>(
          builder: (context, state) {
            if (state.status != RoamingPlanConfirmationStatus.ready ||
                state.data == null) {
              return const SizedBox.shrink();
            }

            return DefaultBottomPayBar(
               buttonText: 'continue',
                isVatExclusive: true,
                isButtonEnabled: state.isTermsChecked,
                buttonColor: const Color(0xFF645D9C),
                onPayNow: () {
                  context.read<RoamingPlanConfirmationBloc>().add(
                    const RoamingPlanConfirmationPayNowPressed(),
                  );
                  final data = state.data!;
                  final primaryPlanName = data.items
                      .firstWhere(
                        (item) =>
                            item.type == PurchaseLineType.primaryPlan,
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
                      'planName':
                          primaryPlanName.isEmpty ? null : primaryPlanName,
                      'addOnNames': addOnNames,
                      'dateText': DateFormat('MMM d, yyyy').format(now),
                      'timeText':
                          DateFormat('h:mm a').format(now).toLowerCase(),
                    },
                  );
                },
                amountText: '\$ 75.00' //total.toString(),
                );
          },
        ),

        body: SafeArea(
          top: false,
          child: BlocBuilder<RoamingPlanConfirmationBloc,
              RoamingPlanConfirmationState>(
            builder: (context, state) {
              final data = state.data;

              return Column(
                children: [
                  /// Top app bar (fixed)
                  DefaultAppBar(
                    showHome: true,
                    onHomeTap: (){
                      context.go(AppRoutes.logIn);
                    },
                    title: 'confirmation and payment',
                    onBack: () {
                      context.pop();
                    },
                    showBackArrow: true,
                    backgroundColor: RoamingPlanConfirmationTheme.purple,
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
                                        RoamingPlanConfirmationTheme
                                            .contentHorizontalPadding,
                                        RoamingPlanConfirmationTheme
                                            .purchaseSummaryCardTopSpacing,
                                        RoamingPlanConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                      ),
                                      child: PurchaseSummaryCard(
                                        showDateField: showDateField,
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<RoamingPlanConfirmationBloc>()
                                            .add(
                                                RoamingPlanConfirmationRemoveItemPressed(
                                                    id)),
                                      ),
                                    ),
                                  ),

                                  if (showDateField)
                                    /// Begins-on info card (optional via navigation flag)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          RoamingPlanConfirmationTheme
                                              .contentHorizontalPadding,
                                          RoamingPlanConfirmationTheme
                                              .beginsOnCardTopSpacing,
                                          RoamingPlanConfirmationTheme
                                              .contentHorizontalPadding,
                                          0,
                                        ),
                                        child: BeginsOnCard(
                                          dateText: data.beginsOnDateText,
                                        ),
                                      ),
                                    ),

                                  /// Terms notice (your exact padding)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        RoamingPlanConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        RoamingPlanConfirmationTheme
                                            .termsNoticeTopSpacing,
                                        RoamingPlanConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        RoamingPlanConfirmationTheme
                                            .termsNoticeBottomSpacing,
                                      ),
                                      child: TermsNotice(
                                        isChecked: state.isTermsChecked,
                                        onToggleChecked: () => context
                                            .read<RoamingPlanConfirmationBloc>()
                                            .add(
                                              RoamingPlanConfirmationTermsCheckboxToggled(
                                                !state.isTermsChecked,
                                              ),
                                            ),
                                        onTermsTap: () async {
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
                                        RoamingPlanConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                        RoamingPlanConfirmationTheme
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
                                            label: 'sub total',
                                            value: '\$ 18.18',
                                            // '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'vat',
                                            value:'\$ 0.0' ,//'\$ ${data.totals.vat.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'total',
                                            value: '\$ 20.00',
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
