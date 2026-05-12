import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
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
    return BlocListener<HomePlanConfirmationBloc, HomePlanConfirmationState>(
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
                                          await _showTermsAndConditionsModal(
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
}

Future<void> _showTermsAndConditionsModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (dialogContext) {
      return const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _TermsAndConditionsDialog(),
      );
    },
  );
}

class _TermsAndConditionsDialog extends StatelessWidget {
  const _TermsAndConditionsDialog();

  static const TextStyle _titleStyle = TextStyle(
    color: Color(0xFF222222),
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 28 / 18,
  );

  static const TextStyle _bodyStyle = TextStyle(
    color: Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );

  static const String _introText =
      'Welcome to the bealiv.com website, which is operated by Cable Bahamas '
      'Group Ltd (“CBL”, “Bealiv”, “ALIV” “MyAliv App,” “we,” “us” or “our”). '
      'Please read these Terms of Use carefully, as they describe the terms '
      'and conditions applicable to bealiv.com in addition to any related '
      'websites, domains, portals, mobile applications, or online services '
      'which may be offered by our affiliate companies, including, but not '
      'limited to, https://portal.newcomobile.com/myaliv/login.aspx, '
      '(collectively, the “Site”). By accessing and using this site, you agree '
      'to comply with and be bound by the following terms of use. Please review '
      'the following terms carefully. If you do not agree to these terms, you '
      'should not use this site.';

  static const String _useOfSiteText =
      'ALIV grants you a limited license to access and make personal use of '
      'this site. You are not permitted to download (other than page caching) '
      'or modify the site, or any portion of it, except with express written '
      'consent of ALIV. This license does not include any resale or commercial '
      'use of this site or its contents; any collection and use of any product '
      'listings, descriptions, or prices; any derivative use of this site or '
      'its contents; any downloading or copying of account information for the '
      'benefit of another merchant; or any use of data mining, robots, or '
      'similar data gathering and extraction tools.';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight - 48),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(
          color: Colors.white,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TermsShieldBadge(),
                    SizedBox(height: 20),
                    Text('Terms & Conditions', style: _titleStyle),
                    SizedBox(height: 20),
                    Text(_introText, style: _bodyStyle),
                    SizedBox(height: 20),
                    Text('Use of Site', style: _titleStyle),
                    SizedBox(height: 20),
                    Text(_useOfSiteText, style: _bodyStyle),
                  ],
                ),
              ),
              Positioned(
                top: 26,
                right: 26,
                child: _TermsDialogCloseButton(
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsShieldBadge extends StatelessWidget {
  const _TermsShieldBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEDE8FA),
      ),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE2DDF5),
        ),
        child: SvgPicture.asset(
          AssetConstant.roundedTikSVG,
          width: 18,
          height: 18.75,
        ),
      ),
    );
  }
}

class _TermsDialogCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TermsDialogCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SvgPicture.asset(
        AssetConstant.blackRoundedCrossSVG,
        width: 24,
        height: 24,
      ),
    );
  }
}
