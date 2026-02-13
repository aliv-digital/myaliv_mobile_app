import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/model/guest_pay_bill_receipt_args.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/guest_pay_bill_confirm_bloc.dart';
import '../bloc/guest_pay_bill_confirm_event.dart';
import '../bloc/guest_pay_bill_confirm_state.dart';
import '../model/guest_pay_bill_confirm_models.dart';
import '../theme/guest_pay_bill_confirm_theme.dart';
import '../widgets/guest_pay_bill_confirm_header_card.dart';
import '../widgets/guest_pay_bill_confirm_terms_row.dart';

class GuestPayBillConfirmScreen extends StatelessWidget {
  const GuestPayBillConfirmScreen({
    super.key,
    required this.args,
  });

  final GuestPayBillConfirmArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GuestPayBillConfirmBloc(args: args);

        // Load VAT and total details as soon as screen opens.
        bloc.add(const GuestPayBillConfirmStarted());

        return bloc;
      },
      child: const _GuestPayBillConfirmView(),
    );
  }
}

class _GuestPayBillConfirmView extends StatelessWidget {
  const _GuestPayBillConfirmView();

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  GuestPayBillConfirmBloc _bloc(BuildContext context) {
    return context.read<GuestPayBillConfirmBloc>();
  }

  String _formatDate(DateTime dateTime) {
    final month = _months[dateTime.month - 1];
    return '$month ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour24 = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'pm' : 'am';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $period';
  }

  String _formatAmount(double amount) {
    return '\$ ${amount.toStringAsFixed(2)}';
  }

  GuestPayBillReceiptArgs _buildReceiptArgs(GuestPayBillConfirmState state) {
    final now = DateTime.now();

    return GuestPayBillReceiptArgs(
      serviceName: state.args.serviceName,
      identifierLabel: state.args.identifierLabel,
      identifierValue: state.args.identifierValue,
      amount: state.total,
      dateText: _formatDate(now),
      timeText: _formatTime(now),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GuestPayBillConfirmTheme.snackBarBackground,
        content: Text(
          message,
          style: GuestPayBillConfirmTheme.snackBarText,
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, GuestPayBillConfirmState state) {
    final errorMessage = state.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      _showSnackBar(context, errorMessage);
    }

    if (state.payStatus == GuestPayBillConfirmPayStatus.success) {
      final receiptArgs = _buildReceiptArgs(state);
      context.push(AppRoutes.guestPayBillReceipt, extra: receiptArgs);
    }
  }

  void _onPayNowPressed(BuildContext context) {
    final bloc = _bloc(context);
    bloc.add(const GuestPayBillConfirmPayNowPressed());
  }

  void _onTermsCheckboxToggled(BuildContext context) {
    final bloc = _bloc(context);
    bloc.add(const GuestPayBillConfirmTermsCheckboxToggled());
  }

  void _onTapTerms(BuildContext context) {
    // TODO: open terms page / modal / webview when route is ready.
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestPayBillConfirmBloc, GuestPayBillConfirmState>(
      listenWhen: (previousState, currentState) {
        final hasErrorChanged =
            previousState.errorMessage != currentState.errorMessage;
        final hasPayStatusChanged =
            previousState.payStatus != currentState.payStatus;

        return hasErrorChanged || hasPayStatusChanged;
      },
      listener: (context, state) {
        _onStateChanged(context, state);
      },
      // Root screen scaffold
      child: Scaffold(
        backgroundColor: GuestPayBillConfirmTheme.pageBg,
        // Sticky bottom pay bar
        bottomNavigationBar:
            BlocBuilder<GuestPayBillConfirmBloc, GuestPayBillConfirmState>(
          buildWhen: (previousState, currentState) {
            final hasTotalChanged = previousState.total != currentState.total;
            final hasPayStatusChanged =
                previousState.payStatus != currentState.payStatus;
            final hasTermsCheckedChanged =
                previousState.isTermsChecked != currentState.isTermsChecked;

            return hasTotalChanged ||
                hasPayStatusChanged ||
                hasTermsCheckedChanged;
          },
          builder: (context, state) {
            // Shared default bottom pay bar component
            return DefaultBottomPayBar(
              amountText: '\$ ${state.total.toStringAsFixed(2)}',
              isLoading:
                  state.payStatus == GuestPayBillConfirmPayStatus.loading,
              buttonText: GuestPayBillConfirmTheme.payNowLabel,
              isVatExclusive: true,
              backgroundColor: Colors.white,
              buttonColor: GuestPayBillConfirmTheme.primary,
              onPayNow: () {
                if (!state.isTermsChecked) {
                  _showSnackBar(
                    context,
                    GuestPayBillConfirmTheme.termsValidationMessage,
                  );
                  return;
                }
                _onPayNowPressed(context);
              },
            );
          },
        ),
        // Main page body
        body: SafeArea(
          // Rebuild body when core confirmation data changes
          child: BlocBuilder<GuestPayBillConfirmBloc, GuestPayBillConfirmState>(
            buildWhen: (previousState, currentState) {
              final hasLoadStatusChanged =
                  previousState.loadStatus != currentState.loadStatus;
              final hasVatChanged = previousState.vat != currentState.vat;
              final hasArgsChanged = previousState.args != currentState.args;
              final hasTermsCheckedChanged =
                  previousState.isTermsChecked != currentState.isTermsChecked;

              return hasLoadStatusChanged ||
                  hasVatChanged ||
                  hasArgsChanged ||
                  hasTermsCheckedChanged;
            },
            builder: (context, state) {
              // Initial loading indicator
              if (state.loadStatus == GuestPayBillConfirmLoadStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Scrollable confirmation content
              return CustomScrollView(
                slivers: [
                  // Top app bar component
                  SliverToBoxAdapter(
                    child: DefaultAppBar(
                      title: GuestPayBillConfirmTheme.appBarTitle,
                      onBack: () {
                        context.pop();
                      },
                    ),
                  ),
                  // Padded body container below app bar
                  SliverPadding(
                    padding: GuestPayBillConfirmTheme.contentPadding,
                    sliver: SliverToBoxAdapter(
                      // Vertical content stack
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top spacing before first card
                          const SizedBox(
                            height: GuestPayBillConfirmTheme.headerTopGap,
                          ),
                          // Summary/header card component
                          GuestPayBillConfirmHeaderCard(
                            serviceName: state.args.serviceName,
                            identifierLabel: state.args.identifierLabel,
                            identifierValue: state.args.identifierValue,
                            amount: state.args.amount,
                          ),
                          // Gap between header and terms
                          const SizedBox(
                            height: GuestPayBillConfirmTheme.sectionGap,
                          ),
                          // Terms and conditions component
                          GuestPayBillConfirmTermsRow(
                            isChecked: state.isTermsChecked,
                            onToggleChecked: () {
                              _onTermsCheckboxToggled(context);
                            },
                            onTapTerms: () {
                              _onTapTerms(context);
                            },
                          ),
                          // Gap between terms and breakdown card
                          const SizedBox(
                            height: GuestPayBillConfirmTheme.sectionGap,
                          ),
                          // Payment breakdown card component
                          CustomPaymentBreakDownCard(
                            items: <CustomPaymentBreakdownLineItem>[
                              CustomPaymentBreakdownLineItem(
                                label: GuestPayBillConfirmTheme.subTotalLabel,
                                value: _formatAmount(state.subTotal),
                              ),
                              CustomPaymentBreakdownLineItem(
                                label: GuestPayBillConfirmTheme.vatLabel,
                                value: _formatAmount(state.vat),
                              ),
                              CustomPaymentBreakdownLineItem(
                                label: GuestPayBillConfirmTheme.totalLabel,
                                value: _formatAmount(state.total),
                              ),
                            ],
                          ),
                          // Bottom breathing space before footer area
                          const SizedBox(
                            height: GuestPayBillConfirmTheme.breakdownBottomGap,
                          ),
                        ],
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
