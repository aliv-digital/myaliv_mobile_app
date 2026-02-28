import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../Aliv-Mobile/revBillPay/revConfirmation/prepaid/theme/rev_confirmation_prepaid_theme.dart';
import '../../../Aliv-Mobile/userProfile/confirmTopUp/prepaid/theme/confirm_top_up_prepaid_theme.dart';
import '../bloc/guest_purchase_plan_confirmation_bloc.dart';
import '../bloc/guest_purchase_plan_confirmation_event.dart';
import '../bloc/guest_purchase_plan_confirmation_state.dart';
import '../repository/guest_purchase_plan_confirmation_repository.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';
import '../widgets/purchase_summary_card.dart';
import '../widgets/terms_notice.dart';

class GuestPurchasePlanConfirmationScreen extends StatelessWidget {
  const GuestPurchasePlanConfirmationScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => GuestPurchasePlanConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPurchasePlanConfirmationBloc(
          repository: ctx.read<GuestPurchasePlanConfirmationRepository>(),
        )..add(GuestPurchasePlanConfirmationStarted(phoneNumber)),
        child: const _GuestPurchasePlanConfirmationView(),
      ),
    );
  }
}

class _GuestPurchasePlanConfirmationView extends StatelessWidget {
  const _GuestPurchasePlanConfirmationView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      GuestPurchasePlanConfirmationBloc,
      GuestPurchasePlanConfirmationState
    >(
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
        backgroundColor: GuestPurchasePlanConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar:
            BlocBuilder<
              GuestPurchasePlanConfirmationBloc,
              GuestPurchasePlanConfirmationState
            >(
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
                    context.push(AppRoutes.guestPurchasePlanReceipt);
                  },
                  amountText:AppSession.appRoute == 'addOnsPrepaid' ? '\$ 15.00': '\$ 75.00', //total.toString(),AppSession.appRoute == 'addOnsPrepaid' ?
                );
              },
            ),

        body: SafeArea(
          child: BlocBuilder<GuestPurchasePlanConfirmationBloc, GuestPurchasePlanConfirmationState>(
            builder: (context, state) {
              final data = state.data;

              return Column(
                children: [
                  /// Top app bar (fixed)
                  DefaultAppBar(
                    height: 63,
                    title: 'confirmation and payment',
                    onBack: () => Navigator.of(context).maybePop(),
                    onHomeTap: () => AppSession.appRoute == 'addOnsPrepaid'
                        ? context.go(AppRoutes.home)
                        : context.go(AppRoutes.logIn),
                    showBackArrow: true,
                    showHome: AppSession.appRoute == 'addOnsPrepaid'
                        ? true
                        : false,
                    backgroundColor: GuestPurchasePlanConfirmationTheme.purple,
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
                                        29,
                                        17,
                                        29,
                                        0,
                                      ),
                                      child: PurchaseSummaryCard(
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<
                                              GuestPurchasePlanConfirmationBloc
                                            >()
                                            .add(
                                              GuestPurchasePlanConfirmationRemoveItemPressed(
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
                                              GuestPurchasePlanConfirmationBloc
                                            >()
                                            .add(
                                              GuestPurchasePlanConfirmationTermsCheckboxToggled(
                                                !state.isTermsChecked,
                                              ),
                                            ),
                                        onTermsTap: () async {
                                          // context
                                          //   .read<
                                          //       GuestPurchasePlanConfirmationBloc>()
                                          //   .add(
                                          //       const GuestPurchasePlanConfirmationTermsPressed());
                                          final uri = Uri.parse(
                                            'https://www.bealiv.com/terms-of-use/',
                                          );

                                          if (!await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          )) {
                                            throw 'Could not open store locator';
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  /// Payment breakdown card
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
                                        input: (AppSession.appRoute == '')
                                            ? null
                                            : CustomPaymentBreakdownInputConfig(
                                                value: '',
                                                enabled: true,
                                                hintText: 'promo code',
                                                actionText: 'apply',
                                                onChanged: (v) {
                                                  // context
                                                  //     .read<RevConfirmationPrepaidBloc>()
                                                  //     .add(RevPromoCodeChanged(v));
                                                },
                                                onActionTap: () {
                                                  // context
                                                  //     .read<RevConfirmationPrepaidBloc>()
                                                  //     .add(const RevPromoApplyPressed());
                                                },
                                              ),
                                        // backgroundColor: HexColor.fromHex('#645D9C'),
                                        items: <CustomPaymentBreakdownLineItem>[
                                          // _promoInput(context),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'sub total',
                                            value: '\$ 75.00',
                                            // '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                                          ),
                                          // CustomPaymentBreakdownLineItem(
                                          //   label: 'sub total',
                                          //   value: '\$ 75.00',
                                          //      // '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                                          // ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'vat',
                                            value:
                                                '\$ ${data.totals.vat.toStringAsFixed(2)}',
                                          ),
                                          CustomPaymentBreakdownLineItem(
                                            label: 'total',
                                            value: '\$ 75.00',
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

  Widget _promoInput(BuildContext context) {
    return Container(
      height: 52, // match figma
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              // controller: controller,
              onChanged: (s) {},
              style: ConfirmTopUpPrepaidTheme.bodyMd(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'promo code',
                hintStyle: TextStyle(
                  color: const Color(0xFFC9C9C9),
                  fontSize: 16,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                'apply',
                style: TextStyle(
                  color: const Color(0xFF645D9C),
                  fontSize: 16,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
