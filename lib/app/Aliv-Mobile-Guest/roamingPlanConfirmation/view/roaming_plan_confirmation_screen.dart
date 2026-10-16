import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/roamingPlanConfirmation/models/roaming_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../../guestPurchasePlan/widgets/roam_bottom_sheet.dart';
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
    final args = RoamingPlanConfirmationRouteArgs.fromExtra(
      GoRouterState.of(context).extra,
      fallbackPhoneNumber: phoneNumber,
      fallbackShowDateField: showDateField,
    );

    return RepositoryProvider(
      create: (_) => RoamingPlanConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => RoamingPlanConfirmationBloc(
          repository: ctx.read<RoamingPlanConfirmationRepository>(),
        )..add(RoamingPlanConfirmationStarted(args)),
        child: _RoamingPlanConfirmationView(
          showDateField: args.showDateField,
          phoneNumber: args.phoneNumber,
        ),
      ),
    );
  }
}

class _RoamingPlanConfirmationView extends StatefulWidget {
  const _RoamingPlanConfirmationView({
    required this.showDateField,
    required this.phoneNumber,
  });

  final bool showDateField;
  final String phoneNumber;

  @override
  State<_RoamingPlanConfirmationView> createState() =>
      _RoamingPlanConfirmationViewState();
}

class _RoamingPlanConfirmationViewState
    extends State<_RoamingPlanConfirmationView> {
  bool _hasNavigatedBack = false;
  bool _isSubmittingPayment = false;

  void _returnToPlanSelection(BuildContext context) {
    if (_hasNavigatedBack || !mounted) return;
    _hasNavigatedBack = true;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go(
        AppRoutes.guestPurchasePlan,
        extra: {'phoneNumber': widget.phoneNumber},
      );
    }
  }

  Future<void> _openCalendarPickerSheet(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final pickedDate = await showGuestRoamCalendarPickerSheet(
      context,
      initialDate: initialDate,
    );

    if (pickedDate == null || !context.mounted) return;

    context.read<RoamingPlanConfirmationBloc>().add(
      RoamingPlanConfirmationBeginDateChanged(pickedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      RoamingPlanConfirmationBloc,
      RoamingPlanConfirmationState
    >(
      listenWhen: (p, c) =>
          p.openTermsRequestId != c.openTermsRequestId ||
          p.payNowRequestId != c.payNowRequestId ||
          p.planRemovedRequestId != c.planRemovedRequestId,
      listener: (context, state) {
        if (state.openTermsRequestId > 0) {
          debugPrint('Open Terms & Conditions');
        }

        if (state.payNowRequestId > 0) {
          debugPrint('Pay Now pressed');
        }

        if (state.planRemovedRequestId > 0) {
          _returnToPlanSelection(context);
        }
      },
      child: Scaffold(
        backgroundColor: RoamingPlanConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar:
            BlocBuilder<
              RoamingPlanConfirmationBloc,
              RoamingPlanConfirmationState
            >(
              builder: (context, state) {
                if (state.status != RoamingPlanConfirmationStatus.ready ||
                    state.data == null) {
                  return const SizedBox.shrink();
                }

                final hasPrimaryPlan = state.hasPrimaryPlan;
                final isEligible =
                    hasPrimaryPlan &&
                    state.isTermsChecked &&
                    (state.data?.totals.total ?? 0) > 0 &&
                    !_isSubmittingPayment;

                return DefaultBottomPayBar(
                  buttonText: 'continue',
                  isVatExclusive: true,
                  isButtonEnabled: isEligible,
                  buttonColor: const Color(0xFF645D9C),
                  onPayNow: () {
                    if (_isSubmittingPayment) return;
                    if (!hasPrimaryPlan) return;
                    if (!state.isTermsChecked) return;

                    final data = state.data;
                    if (data == null ||
                        data.items.isEmpty ||
                        data.totals.total <= 0) {
                      return;
                    }

                    final primaryPlanName =
                        data.items
                            .where(
                              (item) =>
                                  item.type == PurchaseLineType.primaryPlan,
                            )
                            .firstOrNull
                            ?.title ??
                        '';
                    if (primaryPlanName.isEmpty) return;

                    setState(() => _isSubmittingPayment = true);

                    context.read<RoamingPlanConfirmationBloc>().add(
                      const RoamingPlanConfirmationPayNowPressed(),
                    );
                    final addOnNames = data.items
                        .where((item) => item.type == PurchaseLineType.addOn)
                        .map((item) => item.title)
                        .toList(growable: false);
                    final now = DateTime.now();
                    try {
                      context
                          .push(
                            AppRoutes.guestPurchasePlanReceipt,
                            extra: <String, Object?>{
                              'phoneNumber': data.phoneNumber,
                              'amount': data.totals.total,
                              'planName': primaryPlanName,
                              'addOnNames': addOnNames,
                              'dateText': DateFormat('MMM d, yyyy').format(now),
                              'timeText': DateFormat(
                                'h:mm a',
                              ).format(now).toLowerCase(),
                            },
                          )
                          .whenComplete(() {
                            if (mounted) {
                              setState(() => _isSubmittingPayment = false);
                            }
                          });
                    } catch (_) {
                      if (mounted) {
                        setState(() => _isSubmittingPayment = false);
                      }
                    }
                  },
                  amountText: AppUtils.formatPrice(state.data!.totals.total),
                );
              },
            ),

        body: SafeArea(
          top: false,
          child: BlocBuilder<RoamingPlanConfirmationBloc, RoamingPlanConfirmationState>(
            builder: (context, state) {
              final data = state.data;
              final beginDate = state.routeArgs?.beginDate ?? DateTime.now();

              return Column(
                children: [
                  /// Top app bar (fixed)
                  DefaultAppBar(
                    showHome: true,
                    onHomeTap: () {
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
                                        showDateField: widget.showDateField,
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<RoamingPlanConfirmationBloc>()
                                            .add(
                                              RoamingPlanConfirmationRemoveItemPressed(
                                                id,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),

                                  if (widget.showDateField)
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
                                          onCalendarTap: () {
                                            _openCalendarPickerSheet(
                                              context,
                                              beginDate,
                                            );
                                          },
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
                                        backgroundColor: HexColor.fromHex(
                                          '#645D9C',
                                        ),
                                        input: null,
                                        items: <CustomPaymentBreakdownLineItem>[
                                          CustomPaymentBreakdownLineItem(
                                            label: 'sub total',
                                            value: AppUtils.formatPrice(
                                              data.totals.subTotal,
                                            ),
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'vat',
                                            value: AppUtils.formatPrice(
                                              data.totals.vat,
                                            ),
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'total',
                                            value: AppUtils.formatPrice(
                                              data.totals.total,
                                            ),
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
