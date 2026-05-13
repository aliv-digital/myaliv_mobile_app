import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
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
          accountInfoCubit: ctx.read<AccountInfoCubit>(),
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
    return MultiBlocListener(
      listeners: [
        BlocListener<HomePlanConfirmationBloc, HomePlanConfirmationState>(
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
        BlocListener<HomePlanConfirmationBloc, HomePlanConfirmationState>(
          listenWhen: _shouldListenForPromoResult,
          listener: (context, state) {
            switch (state.promoStatus) {
              case HomePlanConfirmationPromoStatus.applied:
                AppToast.show(
                  message: _promoToastMessage(
                    state,
                    fallback: 'Promo code applied successfully.',
                  ),
                  type: ToastType.success,
                );
                break;
              case HomePlanConfirmationPromoStatus.failure:
                AppToast.show(
                  message: _promoToastMessage(
                    state,
                    fallback: 'Invalid promo code.',
                  ),
                  type: ToastType.error,
                );
                break;
              case HomePlanConfirmationPromoStatus.idle:
              case HomePlanConfirmationPromoStatus.applying:
                break;
            }
          },
        ),
      ],
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
          child: BlocBuilder<HomePlanConfirmationBloc, HomePlanConfirmationState>(
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
                                        backgroundColor: HexColor.fromHex(
                                          '#645D9C',
                                        ),
                                        input: CustomPaymentBreakdownInputConfig(
                                          value: state.promoCode,
                                          enabled:
                                              state.promoStatus !=
                                              HomePlanConfirmationPromoStatus
                                                  .applying,
                                          isActionLoading:
                                              state.promoStatus ==
                                              HomePlanConfirmationPromoStatus
                                                  .applying,
                                          onChanged: (value) {
                                            context
                                                .read<
                                                  HomePlanConfirmationBloc
                                                >()
                                                .add(
                                                  HomePlanConfirmationPromoCodeChanged(
                                                    value,
                                                  ),
                                                );
                                          },
                                          onActionTap: () {
                                            FocusScope.of(context).unfocus();
                                            context
                                                .read<
                                                  HomePlanConfirmationBloc
                                                >()
                                                .add(
                                                  const HomePlanConfirmationPromoApplyPressed(),
                                                );
                                          },
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

  bool _shouldListenForNavigationActions(
    HomePlanConfirmationState previous,
    HomePlanConfirmationState current,
  ) {
    final termsActionChanged =
        previous.openTermsRequestId != current.openTermsRequestId;
    final payNowActionChanged =
        previous.payNowRequestId != current.payNowRequestId;

    return termsActionChanged || payNowActionChanged;
  }

  bool _shouldListenForPromoResult(
    HomePlanConfirmationState previous,
    HomePlanConfirmationState current,
  ) {
    final promoStatusChanged = previous.promoStatus != current.promoStatus;
    final promoFinished = _isPromoFinished(current.promoStatus);

    return promoStatusChanged && promoFinished;
  }

  bool _isPromoFinished(HomePlanConfirmationPromoStatus status) {
    return status == HomePlanConfirmationPromoStatus.applied ||
        status == HomePlanConfirmationPromoStatus.failure;
  }

  String _promoToastMessage(
    HomePlanConfirmationState state, {
    required String fallback,
  }) {
    final stateToastMessage = state.promoToastMessage.trim();
    if (stateToastMessage.isNotEmpty) {
      return stateToastMessage;
    }

    if (state.promoStatus == HomePlanConfirmationPromoStatus.failure) {
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

    return fallback;
  }
}
