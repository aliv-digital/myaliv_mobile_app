import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../../../router/app_routes.dart';
import '../bloc/home_plans_payment_method_bloc.dart';
import '../bloc/home_plans_payment_method_event.dart';
import '../bloc/home_plans_payment_method_state.dart';
import '../model/home_plans_payment_method_models.dart';
import '../repository/home_plans_payment_method_repository_impl.dart';
import '../theme/home_plans_payment_method_theme.dart';
import '../widgets/home_plans_payment_method_section.dart';

class HomePlansPaymentMethodScreen extends StatelessWidget {
  final HomePlansPaymentMethodRouteArgs args;

  const HomePlansPaymentMethodScreen({
    super.key,
    this.args = const HomePlansPaymentMethodRouteArgs(),
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocProvider(
      create: (_) {
        final HomePlansPaymentMethodBloc bloc = HomePlansPaymentMethodBloc(
          repository: HomePlansPaymentMethodRepositoryImpl(),
        );

        // Send the initial screen configuration to the bloc.
        bloc.add(
          HomePlansPaymentMethodStarted(
            subscriberType: args.subscriberType,
            walletBalance: args.walletBalance,
          ),
        );

        return bloc;
      },
      child: const _HomePlansPaymentMethodView(),
    );
  }
}

class _HomePlansPaymentMethodView extends StatelessWidget {
  const _HomePlansPaymentMethodView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomePlansPaymentMethodBloc,
        HomePlansPaymentMethodState>(
      listenWhen: (p, c) =>
          p.navTarget != c.navTarget || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        // Show API/validation errors from bloc.
        if (state.errorMessage != null &&
            state.status == HomePlansPaymentMethodStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        // Handle one-time navigation targets from bloc.
        if (state.navTarget != HomePlansPaymentMethodNavTarget.none) {
          if (state.navTarget == HomePlansPaymentMethodNavTarget.addCard) {
            // TODO: Add route when add-card screen is ready.
          } else if (state.navTarget ==
              HomePlansPaymentMethodNavTarget.wallet) {
            // TODO: Add route when wallet payment screen is ready.
          } else if (state.navTarget == HomePlansPaymentMethodNavTarget.paid) {
            // TODO: Add route when payment success screen is ready.
          }

          context
              .read<HomePlansPaymentMethodBloc>()
              .add(const HomePlansPaymentNavConsumed());
        }
      },
      builder: (context, state) {
        final isLoading = state.status == HomePlansPaymentMethodStatus.loading;
        final isSubmitting =
            state.status == HomePlansPaymentMethodStatus.submitting;

        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: HomePlansPaymentMethodTheme.bg,
            bottomNavigationBar: DefaultBottomPayBar(
              amountText: state.amountText,
              isVatExclusive: state.vatNote.toLowerCase().contains('no vat applied'),
              isButtonEnabled: state.isPayNowEnabled,
              isLoading: isSubmitting,
              buttonColor: HomePlansPaymentMethodTheme.payBtnBg,
              onPayNow: () {
                context.push(AppRoutes.homePlanPurchaseReceiptScreen,extra: {
                  'hideSaveCreditCard' : true
                });
                // context
                //     .read<HomePlansPaymentMethodBloc>()
                //     .add(const HomePlansPayNowPressed());
              },
            ),
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: HomePlansPaymentMethodTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: 'payment',
                      height: HomePlansPaymentMethodTheme.appBarHeight,
                      backgroundColor: HomePlansPaymentMethodTheme.appBarBg,
                      showBackArrow: true,
                      showHome: true,
                      onBack: () => context.pop(),
                      onHomeTap: () => context.go(AppRoutes.home),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(29, 24, 29, 20),
                        sliver: SliverToBoxAdapter(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : HomePlansPaymentMethodSection(
                                  methods: state.methods,
                                  selectedId: state.selectedMethodId,
                                  onSelect: (String id) {
                                    context.read<HomePlansPaymentMethodBloc>().add(HomePlansPaymentMethodSelected(id));
                                  },
                                  onPayWithCard: () {
                                    context.push(AppRoutes.homePlanPurchaseReceiptScreen);
                                    // context.read<HomePlansPaymentMethodBloc>().add(
                                    //       const HomePlansPayWithCardPressed(),
                                    //     );
                                  },
                                  showPayFromWallet: state.isPrepaidUser,
                                  walletBalanceText: state.walletBalanceText,
                                  onPayFromWallet: () {
                                    context
                                        .read<HomePlansPaymentMethodBloc>()
                                        .add(
                                          const HomePlansPayFromWalletPressed(),
                                        );
                                  },
                                ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
