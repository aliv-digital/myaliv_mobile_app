import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/confirm_topup_bloc.dart';
import '../bloc/confirm_topup_event.dart';
import '../bloc/confirm_topup_state.dart';
import '../repository/confirm_topup_repository.dart';
import '../theme/theme.dart';
import '../widgets/terms_and_conditions_text.dart';
import '../widgets/topup_summary_card.dart';

class GuestConfirmTopUpScreen extends StatelessWidget {
  const GuestConfirmTopUpScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
  });

  final String phoneNumber;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) {
        return GuestConfirmTopUpRepository();
      },
      child: BlocProvider(
        create: (context) {
          final repository = context.read<GuestConfirmTopUpRepository>();
          final bloc = GuestConfirmTopUpBloc(repository: repository);

          // Seed initial values for this screen from route arguments.
          bloc.add(
            GuestConfirmTopUpStarted(
              phoneNumber: phoneNumber,
              amount: amount,
            ),
          );

          return bloc;
        },
        child: const _GuestConfirmTopUpView(),
      ),
    );
  }
}

class _GuestConfirmTopUpView extends StatelessWidget {
  const _GuestConfirmTopUpView();

  String _formatCurrency(double amount) {
    return '\$ ${amount.toStringAsFixed(2)}';
  }

  void _showSnackBar(BuildContext context, String message) {
    AppToast.show(message: message.toString());
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       message,
    //       style: TopUpConfirmTheme.snackBarText,
    //     ),
    //   ),
    // );
  }

  void _openTerms(BuildContext context) {
    // TODO: open terms page / modal / webview
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
      listenWhen: (previousState, currentState) {
        final hasStatusChanged = previousState.status != currentState.status;
        final hasTermsRequestChanged =
            previousState.termsRequestId != currentState.termsRequestId;
        return hasStatusChanged || hasTermsRequestChanged;
      },
      listener: (context, state) {
        if (state.status == GuestConfirmTopUpStatus.success) {
          _showSnackBar(context, 'Payment successful');
        }

        if (state.status == GuestConfirmTopUpStatus.failure) {
          final errorMessage = state.errorMessage ?? 'Payment failed';
          _showSnackBar(context, errorMessage);
        }

        if (state.termsRequestId != 0) {
          _openTerms(context);
        }
      },
      child: Scaffold(
        backgroundColor: TopUpConfirmTheme.screenBackgroundColor,
        bottomNavigationBar:
            BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
          buildWhen: (previousState, currentState) {
            // Bottom pay bar depends on total amount and loading status.
            final hasTotalChanged = previousState.total != currentState.total;
            final hasStatusChanged =
                previousState.status != currentState.status;

            return hasTotalChanged || hasStatusChanged;
          },
          builder: (context, state) {
            final amountText = _formatCurrency(state.total);
            final isLoading = state.status == GuestConfirmTopUpStatus.loading;

            return DefaultBottomPayBar(
              amountText: amountText,
              
              isLoading: isLoading,
              buttonText: TopUpConfirmTheme.payNowLabel,
              isVatExclusive: true,
              backgroundColor: TopUpConfirmTheme.payBarBackgroundColor,
              buttonColor: TopUpConfirmTheme.payBarButtonColor,
              onPayNow: () {
                // If payment should be done by BLoC flow, use:
                // final bloc = context.read<GuestConfirmTopUpBloc>();
                // bloc.add(
                //   const GuestConfirmTopUpPayNowPressed(),
                // );
                context.push(AppRoutes.guestTopUpReceipt);
              },
            );
          },
        ),
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  backgroundColor: TopUpConfirmTheme.appBarColor,
                  title: 'confirmation and payment',
                  onBack: () {
                    context.pop();
                  },
                    onHomeTap: () => context.go(AppRoutes.home)

                ),
              ),

              // 1) Top card
              SliverToBoxAdapter(
                child: Padding(
                  padding: TopUpConfirmTheme.summaryWrapperPadding,
                  child: BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                    buildWhen: (previousState, currentState) {
                      // Rebuild only when the values shown in TopUpSummaryCard change.
                      final hasPhoneNumberChanged = previousState.phoneNumber != currentState.phoneNumber;
                      final hasAmountChanged = previousState.total != currentState.total;

                      return hasPhoneNumberChanged || hasAmountChanged;
                    },
                    builder: (context, state) {
                      return TopUpSummaryCard(
                        phoneNumber: state.phoneNumber,
                        amountText: _formatCurrency(state.total),
                      );
                    },
                  ),
                ),
              ),

              // 2) Terms text
              SliverToBoxAdapter(
                child: Padding(
                  padding: TopUpConfirmTheme.termsWrapperPadding,
                  child: BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                    builder: (context, state) {
                      return TermsAndConditionsText(
                        isChecked: state.isTermsChecked,
                        onToggleChecked: () {
                          final bloc = context.read<GuestConfirmTopUpBloc>();
                          bloc.add(const GuestConfirmTopUpTermsCheckboxToggled());
                        },
                        onTapTerms: () async {
                          await showTermsAndConditionsModal(context);
                        },
                      );
                    },
                  ),
                ),
              ),

              // 3) Payment breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: TopUpConfirmTheme.breakdownWrapperPadding,
                  child: BlocBuilder<GuestConfirmTopUpBloc, GuestConfirmTopUpState>(
                    buildWhen: (previousState, currentState) {
                      final hasSubTotalChanged = previousState.subTotal != currentState.subTotal;
                      final hasVatChanged = previousState.vat != currentState.vat;
                      final hasTotalChanged = previousState.total != currentState.total;

                      return hasSubTotalChanged || hasVatChanged || hasTotalChanged;
                    },
                    builder: (context, state) {
                      // Local card kept for reference:
                      // return PaymentBreakdownCard(
                      //   subTotal: state.subTotal,
                      //   vat: state.vat,
                      //   total: state.total,
                      // );
                      final items = <CustomPaymentBreakdownLineItem>[
                        CustomPaymentBreakdownLineItem(
                          
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: AppConstants.defaultFontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                          label: 'sub total',
                          value: _formatCurrency(state.subTotal),
                        ),
                        CustomPaymentBreakdownLineItem(
                          label: 'vat',
                          value: _formatCurrency(state.vat),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: AppConstants.defaultFontFamily,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                        CustomPaymentBreakdownLineItem(
                          label: 'total',
                          value: _formatCurrency(state.total),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: AppConstants.defaultFontFamily,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                      ];

                      return CustomPaymentBreakDownCard(
                        gapAfterDivider: 24,
                        gapBeforeDivider: 24,
                          backgroundColor: HexColor.fromHex('#645D9C'),
                          items: items
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: TopUpConfirmTheme.bottomScrollSpacing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
