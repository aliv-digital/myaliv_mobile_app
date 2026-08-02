import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/addOnsConfirmation/models/add_ons_confirmation_models.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../bloc/add_ons_confirmation_bloc.dart';
import '../bloc/add_ons_confirmation_event.dart';
import '../bloc/add_ons_confirmation_state.dart';
import '../repository/add_ons_confirmation_repository.dart';
import '../theme/add_ons_confirmation_theme.dart';
import '../widgets/purchase_summary_card.dart';
import '../widgets/terms_notice.dart';

class AddOnsConfirmationScreen extends StatelessWidget {
  const AddOnsConfirmationScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AddOnsConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => AddOnsConfirmationBloc(
          repository: ctx.read<AddOnsConfirmationRepository>(),
        )..add(AddOnsConfirmationStarted(phoneNumber)),
        child: const _AddOnsConfirmationView(),
      ),
    );
  }
}

class _AddOnsConfirmationView extends StatelessWidget {
  const _AddOnsConfirmationView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddOnsConfirmationBloc,
        AddOnsConfirmationState>(
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
        backgroundColor: AddOnsConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar: BlocBuilder<AddOnsConfirmationBloc,
            AddOnsConfirmationState>(
          builder: (context, state) {
            if (state.status != AddOnsConfirmationStatus.ready ||
                state.data == null) {
              return const SizedBox.shrink();
            }

            return DefaultBottomPayBar(
                buttonText: 'continue',
                isVatExclusive: true,
                isButtonEnabled: state.isTermsChecked,
                buttonColor: const Color(0xFF645D9C),
                onPayNow: () {
                  context.read<AddOnsConfirmationBloc>().add(
                    const AddOnsConfirmationPayNowPressed(),
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
                amountText: '\$ ${state.data!.totals.total.toStringAsFixed(2)}',
            );
          },
        ),

        body: SafeArea(
          top: false,
          child: BlocBuilder<AddOnsConfirmationBloc,
              AddOnsConfirmationState>(
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
                    backgroundColor: AddOnsConfirmationTheme.purple,
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
                                        AddOnsConfirmationTheme
                                            .contentHorizontalPadding,
                                        AddOnsConfirmationTheme
                                            .purchaseSummaryCardTopSpacing,
                                        AddOnsConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                      ),
                                      child: PurchaseSummaryCard(
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<AddOnsConfirmationBloc>()
                                            .add(
                                                AddOnsConfirmationRemoveItemPressed(
                                                    id)),
                                      ),
                                    ),
                                  ),

                                  /// Terms notice (your exact padding)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        AddOnsConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        AddOnsConfirmationTheme
                                            .termsNoticeTopSpacing,
                                        AddOnsConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        AddOnsConfirmationTheme
                                            .termsNoticeBottomSpacing,
                                      ),
                                      child: TermsNotice(
                                        isChecked: state.isTermsChecked,
                                        onToggleChecked: () => context
                                            .read<AddOnsConfirmationBloc>()
                                            .add(
                                              AddOnsConfirmationTermsCheckboxToggled(
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
                                        AddOnsConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                        AddOnsConfirmationTheme
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
