import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/addOnsConfirmation/models/add_ons_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_request.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
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
  const AddOnsConfirmationScreen({super.key, required this.args});

  final AddOnsConfirmationRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AddOnsConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => AddOnsConfirmationBloc(
          repository: ctx.read<AddOnsConfirmationRepository>(),
        )..add(AddOnsConfirmationStarted(args)),
        child: _AddOnsConfirmationView(args: args),
      ),
    );
  }
}

class _AddOnsConfirmationView extends StatefulWidget {
  const _AddOnsConfirmationView({required this.args});

  final AddOnsConfirmationRouteArgs args;

  @override
  State<_AddOnsConfirmationView> createState() =>
      _AddOnsConfirmationViewState();
}

class _AddOnsConfirmationViewState extends State<_AddOnsConfirmationView> {
  bool _isSubmittingPayment = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddOnsConfirmationBloc, AddOnsConfirmationState>(
      listenWhen: (p, c) => p.openTermsRequestId != c.openTermsRequestId,
      listener: (context, state) {
        // Future: open terms page / bottom sheet
      },
      child: Scaffold(
        backgroundColor: AddOnsConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar:
            BlocBuilder<AddOnsConfirmationBloc, AddOnsConfirmationState>(
              builder: (context, state) {
                if (state.status != AddOnsConfirmationStatus.ready ||
                    state.data == null) {
                  return const SizedBox.shrink();
                }

                final bool isButtonEnabled =
                    state.isTermsChecked && !_isSubmittingPayment;

                return DefaultBottomPayBar(
                  buttonText: 'continue',
                  isVatExclusive: true,
                  isButtonEnabled: isButtonEnabled,
                  buttonColor: const Color(0xFF645D9C),
                  onPayNow: () => _onContinuePressed(context, state),
                  amountText: AppUtils.formatPrice(state.data!.totals.total),
                );
              },
            ),

        body: SafeArea(
          top: false,
          child: BlocBuilder<AddOnsConfirmationBloc, AddOnsConfirmationState>(
            builder: (context, state) {
              final data = state.data;

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
                                        backgroundColor: HexColor.fromHex(
                                          '#645D9C',
                                        ),
                                        input: null,
                                        items: <CustomPaymentBreakdownLineItem>[
                                          CustomPaymentBreakdownLineItem(
                                            label: 'subtotal',
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

  /// Mirrors `guest_purchase_plan_confirmation_screen.dart:128-260`:
  /// build the `/Guest/purchaseplan` 3DS body, open PaymentIFrameScreen,
  /// on success push the receipt with the real orderId.
  void _onContinuePressed(BuildContext context, AddOnsConfirmationState state) {
    if (_isSubmittingPayment) return;
    if (!state.isTermsChecked) return;

    final data = state.data;
    if (data == null) return;

    // Convert the live confirmation line items back to numeric plan ids —
    // the user may have removed one via the remove button, so prefer the
    // currently-displayed items over the original route args.
    final List<int> addOnPlanIds = data.items
        .where((item) => item.type == PurchaseLineType.addOn)
        .map((item) => int.tryParse(item.id))
        .whereType<int>()
        .toList(growable: false);

    if (addOnPlanIds.isEmpty || data.totals.total <= 0) {
      AppToast.show(
        message: 'No add-ons selected. Please try again.',
        type: ToastType.error,
      );
      return;
    }

    final addOnNames = data.items
        .where((item) => item.type == PurchaseLineType.addOn)
        .map((item) => item.title)
        .toList(growable: false);
    final now = DateTime.now();
    final receiptExtra = <String, Object?>{
      'phoneNumber': data.phoneNumber,
      'amount': data.totals.total,
      'planName': null,
      'addOnNames': addOnNames,
      'dateText': DateFormat('MMM d, yyyy').format(now),
      'timeText': DateFormat('h:mm a').format(now).toLowerCase(),
      'emailAddress': 'guest',
    };

    final body = ChangeBundleRequestFactory.guestAddOnsBodyFor3DS(
      addOnPlanIds: addOnPlanIds,
      phoneNumber: data.phoneNumber,
    );

    final request = PaymentRequest(
      url: Api.guestPurchasePlanUrl,
      body: body,
      redirectScheme: 'myaliv',
      skipAuth: true,
    );

    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSubmittingPayment = true);

    try {
      navigator
          .push(
            MaterialPageRoute<void>(
              builder: (_) => PaymentIFrameScreen(
                request: request,
                appBarBgColor: Colors.white,
                title: 'payment',
                onSuccess: (PaymentSuccess success) {
                  final orderId = int.tryParse(success.orderId ?? '');
                  if (orderId == null || orderId <= 0) {
                    navigator.pop();
                    AppToast.show(
                      message:
                          'Payment could not be confirmed. Please try again.',
                      type: ToastType.error,
                    );
                    return;
                  }
                  receiptExtra['orderId'] = success.orderId;
                  navigator.pop();
                  router.push(
                    AppRoutes.guestPurchasePlanReceipt,
                    extra: receiptExtra,
                  );
                },
                onFailure: (String message) {
                  navigator.pop();
                  AppToast.show(message: message, type: ToastType.error);
                },
              ),
            ),
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
  }
}
