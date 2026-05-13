import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/start_plan_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../resources/widgets/terms_and_conditions_modal.dart';
import '../bloc/home_roaming_confirmation_bloc.dart';
import '../bloc/home_roaming_confirmation_event.dart';
import '../bloc/home_roaming_confirmation_state.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../repository/home_roaming_confirmation_repository.dart';
import '../theme/home_roaming_confirmation_theme.dart';
import '../widgets/home_roaming_confirmation_begins_on_card.dart';
import '../widgets/home_roaming_confirmation_purchase_summary_card.dart';
import '../widgets/home_roaming_confirmation_terms_notice.dart';

class HomeRoamingConfirmationScreen extends StatelessWidget {
  const HomeRoamingConfirmationScreen({super.key, required this.args});

  final HomeRoamingConfirmationRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => HomeRoamingConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => HomeRoamingConfirmationBloc(
          repository: ctx.read<HomeRoamingConfirmationRepository>(),
          accountInfoCubit: ctx.read<AccountInfoCubit>(),
        )..add(HomeRoamingConfirmationStarted(args)),
        child: _HomeRoamingConfirmationView(showDateField: args.showDateField),
      ),
    );
  }
}

class _HomeRoamingConfirmationView extends StatelessWidget {
  const _HomeRoamingConfirmationView({required this.showDateField});

  final bool showDateField;

  Future<void> _openCalendarPickerSheet(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final pickedDate = await showStartPlanCalendarPickerSheet(
      context,
      initialDate: initialDate,
    );

    if (pickedDate == null || !context.mounted) return;

    context.read<HomeRoamingConfirmationBloc>().add(
      HomeRoamingConfirmationBeginDateChanged(pickedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeRoamingConfirmationBloc, HomeRoamingConfirmationState>(
          listenWhen: _shouldListenForNavigationActions,
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
        ),
        BlocListener<HomeRoamingConfirmationBloc, HomeRoamingConfirmationState>(
          listenWhen: _shouldListenForPromoResult,
          listener: (context, state) {
            switch (state.promoStatus) {
              case HomeRoamingConfirmationPromoStatus.applied:
                AppToast.show(
                  message: _promoToastMessage(
                    state,
                    fallback: 'Promo code applied successfully.',
                  ),
                  type: ToastType.success,
                );
                break;
              case HomeRoamingConfirmationPromoStatus.failure:
                AppToast.show(
                  message: _promoToastMessage(
                    state,
                    fallback: 'Invalid promo code.',
                  ),
                  type: ToastType.error,
                );
                break;
              case HomeRoamingConfirmationPromoStatus.idle:
              case HomeRoamingConfirmationPromoStatus.applying:
                break;
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: HomeRoamingConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar:
            BlocBuilder<
              HomeRoamingConfirmationBloc,
              HomeRoamingConfirmationState
            >(
              builder: (context, state) {
                if (state.status != HomeRoamingConfirmationStatus.ready ||
                    state.data == null) {
                  return const SizedBox.shrink();
                }

                return DefaultBottomPayBar(
                  buttonText: 'continue',
                  isVatExclusive: true,
                  isButtonEnabled: state.isTermsChecked,
                  buttonColor: const Color(0xFF645D9C),
                  onPayNow: () {
                    context.read<HomeRoamingConfirmationBloc>().add(
                      const HomeRoamingConfirmationPayNowPressed(),
                    );
                    context.push(
                      AppRoutes.homePlansPaymentMethodScreen,
                      extra: HomePlansPaymentMethodRouteArgs(
                        amount: state.data!.totals.total,
                        vatNote: state.data!.totals.vat > 0
                            ? 'vat included'
                            : 'no vat applied',
                        selectedItems: state.data!.items
                            .map(
                              (item) => HomePlansPaymentSelectedItem(
                                id: item.id,
                                label: item.label,
                                title: item.title,
                                subtitle: item.subtitle,
                                price: item.price,
                                planType: HomePlansPaymentPlanType.fromCode(
                                  item.planTypeCode,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    );
                  },
                  amountText:
                      '\$ ${state.data!.totals.total.toStringAsFixed(2)}',
                );
              },
            ),

        body: SafeArea(
          child: BlocBuilder<HomeRoamingConfirmationBloc, HomeRoamingConfirmationState>(
            builder: (context, state) {
              final data = state.data;
              final beginDate = state.routeArgs?.beginDate ?? DateTime.now();

              return Column(
                children: [
                  /// Top app bar (fixed)
                  DefaultAppBar(
                    showHome: true,
                    onHomeTap: () {
                      context.go(AppRoutes.home);
                    },
                    title: 'confirmation and payment',
                    onBack: () => Navigator.of(context).maybePop(),
                    showBackArrow: true,
                    backgroundColor: HomeRoamingConfirmationTheme.purple,
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
                                        HomeRoamingConfirmationTheme
                                            .contentHorizontalPadding,
                                        HomeRoamingConfirmationTheme
                                            .purchaseSummaryCardTopSpacing,
                                        HomeRoamingConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                      ),
                                      child: HomeRoamingConfirmationPurchaseSummaryCard(
                                        showDateField: showDateField,
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<HomeRoamingConfirmationBloc>()
                                            .add(
                                              HomeRoamingConfirmationRemoveItemPressed(
                                                id,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),

                                  if (showDateField)
                                    /// Begins-on info card (optional via navigation flag)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          HomeRoamingConfirmationTheme
                                              .contentHorizontalPadding,
                                          HomeRoamingConfirmationTheme
                                              .beginsOnCardTopSpacing,
                                          HomeRoamingConfirmationTheme
                                              .contentHorizontalPadding,
                                          0,
                                        ),
                                        child:
                                            HomeRoamingConfirmationBeginsOnCard(
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
                                        HomeRoamingConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        HomeRoamingConfirmationTheme
                                            .termsNoticeTopSpacing,
                                        HomeRoamingConfirmationTheme
                                            .termsNoticeHorizontalPadding,
                                        HomeRoamingConfirmationTheme
                                            .termsNoticeBottomSpacing,
                                      ),
                                      child: HomeRoamingConfirmationTermsNotice(
                                        isChecked: state.isTermsChecked,
                                        onToggleChecked: () => context
                                            .read<HomeRoamingConfirmationBloc>()
                                            .add(
                                              HomeRoamingConfirmationTermsCheckboxToggled(
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
                                        HomeRoamingConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                        HomeRoamingConfirmationTheme
                                            .contentHorizontalPadding,
                                        0,
                                      ),
                                      child: CustomPaymentBreakDownCard(
                                        backgroundColor: HexColor.fromHex(
                                          '#645D9C',
                                        ),
                                        input: CustomPaymentBreakdownInputConfig(
                                          value: state.promoCode,
                                          enabled:
                                              state.promoStatus !=
                                              HomeRoamingConfirmationPromoStatus
                                                  .applying,
                                          isActionLoading:
                                              state.promoStatus ==
                                              HomeRoamingConfirmationPromoStatus
                                                  .applying,
                                          onChanged: (value) {
                                            context
                                                .read<
                                                  HomeRoamingConfirmationBloc
                                                >()
                                                .add(
                                                  HomeRoamingConfirmationPromoCodeChanged(
                                                    value,
                                                  ),
                                                );
                                          },
                                          onActionTap: () {
                                            FocusScope.of(context).unfocus();
                                            context
                                                .read<
                                                  HomeRoamingConfirmationBloc
                                                >()
                                                .add(
                                                  const HomeRoamingConfirmationPromoApplyPressed(),
                                                );
                                          },
                                          hintText: 'promo code',
                                          actionText: 'apply',
                                        ),
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

  bool _shouldListenForNavigationActions(
    HomeRoamingConfirmationState previous,
    HomeRoamingConfirmationState current,
  ) {
    final termsActionChanged =
        previous.openTermsRequestId != current.openTermsRequestId;
    final payNowActionChanged =
        previous.payNowRequestId != current.payNowRequestId;

    return termsActionChanged || payNowActionChanged;
  }

  bool _shouldListenForPromoResult(
    HomeRoamingConfirmationState previous,
    HomeRoamingConfirmationState current,
  ) {
    final promoStatusChanged = previous.promoStatus != current.promoStatus;
    final promoFinished = _isPromoFinished(current.promoStatus);

    return promoStatusChanged && promoFinished;
  }

  bool _isPromoFinished(HomeRoamingConfirmationPromoStatus status) {
    return status == HomeRoamingConfirmationPromoStatus.applied ||
        status == HomeRoamingConfirmationPromoStatus.failure;
  }

  String _promoToastMessage(
    HomeRoamingConfirmationState state, {
    required String fallback,
  }) {
    if (state.promoStatus == HomeRoamingConfirmationPromoStatus.failure) {
      final errorMessage = state.promoErrorMessage.trim();
      if (errorMessage.isNotEmpty) {
        return errorMessage;
      }
    }

    final responseDescription =
        state.promoResponse?.textAtPath('Definition.PromoCodeDesc') ?? '';
    if (responseDescription.trim().isNotEmpty) {
      return responseDescription.trim();
    }

    final responseName =
        state.promoResponse?.textAtPath('Definition.PromoCodeName') ?? '';
    if (responseName.trim().isNotEmpty) {
      return responseName.trim();
    }

    final responseValue = state.promoResponse?.textAtPath('Value') ?? '';
    if (responseValue.trim().isNotEmpty) {
      return responseValue.trim();
    }

    return fallback;
  }
}
