import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../bloc/home_roaming_confirmation_bloc.dart';
import '../bloc/home_roaming_confirmation_event.dart';
import '../bloc/home_roaming_confirmation_state.dart';
import '../repository/home_roaming_confirmation_repository.dart';
import '../theme/home_roaming_confirmation_theme.dart';
import '../widgets/home_roaming_confirmation_begins_on_card.dart';
import '../widgets/home_roaming_confirmation_purchase_summary_card.dart';
import '../widgets/home_roaming_confirmation_terms_notice.dart';

class HomeRoamingConfirmationScreen extends StatelessWidget {
  const HomeRoamingConfirmationScreen({
    super.key,
    required this.phoneNumber,
    this.showDateField = true,
  });

  final String phoneNumber;
  final bool showDateField;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => HomeRoamingConfirmationRepository(),
      child: BlocProvider(
        create: (ctx) => HomeRoamingConfirmationBloc(
          repository: ctx.read<HomeRoamingConfirmationRepository>(),
        )..add(HomeRoamingConfirmationStarted(phoneNumber)),
        child: _HomeRoamingConfirmationView(showDateField: showDateField),
      ),
    );
  }
}

class _HomeRoamingConfirmationView extends StatelessWidget {
  const _HomeRoamingConfirmationView({
    required this.showDateField,
  });

  final bool showDateField;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeRoamingConfirmationBloc,
        HomeRoamingConfirmationState>(
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
        backgroundColor: HomeRoamingConfirmationTheme.bg,

        /// fixed bottom (AddOns pattern)
        bottomNavigationBar: BlocBuilder<HomeRoamingConfirmationBloc,
            HomeRoamingConfirmationState>(
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
                  context.push(AppRoutes.homePlansPaymentMethodScreen);
                },
                amountText: '\$ 75.00' //total.toString(),
                );
          },
        ),

        body: SafeArea(
          child: BlocBuilder<HomeRoamingConfirmationBloc,
              HomeRoamingConfirmationState>(
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
                                      child:
                                          HomeRoamingConfirmationPurchaseSummaryCard(
                                        showDateField: showDateField,
                                        data: data,
                                        onRemoveItem: (id) => context
                                            .read<HomeRoamingConfirmationBloc>()
                                            .add(
                                                HomeRoamingConfirmationRemoveItemPressed(
                                                    id)),
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
                                          final uri = Uri.parse(
                                            'https://www.bealiv.com/terms-of-use/',
                                          );

                                          await launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
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
                                            value:
                                                '\$ 1.82', //'\$ ${data.totals.vat.toStringAsFixed(2)}',
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
