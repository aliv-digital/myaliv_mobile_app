import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../../core/utils/app_session.dart';
import '../../../Guest-Pay-Bill/pay-bill-receipts/model/guest_pay_bill_receipt_args.dart';
import '../bloc/guest_payment_method_prepaid_bloc.dart';
import '../bloc/guest_payment_method_prepaid_event.dart';
import '../bloc/guest_payment_method_prepaid_state.dart';
import '../repository/guest_payment_method_prepaid_repository_impl.dart';
import '../theme/guest_payment_method_prepaid_theme.dart';
import '../widgets/guest_payment_method_section.dart';

class GuestPaymentMethodPrepaidScreen extends StatelessWidget {
  const GuestPaymentMethodPrepaidScreen({super.key});

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
      create: (_) => GuestPaymentMethodPrepaidBloc(
        repository: GuestPaymentMethodPrepaidRepositoryImpl(),
      )..add(const GuestPaymentMethodPrepaidStarted()),
      child: const _GuestPaymentMethodPrepaidView(),
    );
  }
}

class _GuestPaymentMethodPrepaidView extends StatelessWidget {
  const _GuestPaymentMethodPrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GuestPaymentMethodPrepaidBloc,
        GuestPaymentMethodPrepaidState>(
      listenWhen: (p, c) =>
          p.navTarget != c.navTarget || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        // if (state.errorMessage != null &&
        //     state.status == GuestPaymentMethodPrepaidStatus.failure) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text(state.errorMessage!)),
        //   );
        // }

        if (state.navTarget != GuestPaymentMethodNavTarget.none) {
          // TODO: handle navigation when you need
          // if (state.navTarget == GuestPaymentMethodNavTarget.addCard) { ... }
          // if (state.navTarget == GuestPaymentMethodNavTarget.paid) { ... }

          context
              .read<GuestPaymentMethodPrepaidBloc>()
              .add(const GuestPaymentNavConsumed());
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == GuestPaymentMethodPrepaidStatus.loading;
        final isSubmitting =
            state.status == GuestPaymentMethodPrepaidStatus.submitting;

        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: GuestPaymentMethodPrepaidTheme.bg,
            bottomNavigationBar: DefaultBottomPayBar(
              
              amountText:'\$ 20.00' ,//state.amountText,
              isVatExclusive:
                  state.vatNote.toLowerCase().contains('no vat applied'),
              isButtonEnabled: state.isPayNowEnabled,
              isLoading: isSubmitting,
              buttonColor: GuestPaymentMethodPrepaidTheme.payBtnBg,
              // onPayNow: () => context
              //     .read<GuestPaymentMethodPrepaidBloc>()
              //     .add(const GuestPayNowPressed()),
              onPayNow: (){
                // context.go(AppRoutes.guestPurchasePlanReceipt,);
                AppSession.appRoute = 'postpaidPayment';
                context.push(
                  AppRoutes.guestPayBillReceipt,
                  extra: GuestPayBillReceiptArgs(
                    serviceName: 'ALIV Postpaid',
                    identifierLabel: 'phone no.',
                    identifierValue: '242-801-1616',
                    amount: 20.00,
                    dateText: 'Mar 22, 2023',
                    timeText: '07:30 am',
                  ),
                );
              },
            ),
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: GuestPaymentMethodPrepaidTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: 'payment',
                      height: GuestPaymentMethodPrepaidTheme.appBarHeight,
                      backgroundColor: GuestPaymentMethodPrepaidTheme.appBarBg,
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
                              : GuestPaymentMethodSection(
                                  methods: state.methods,
                                  selectedId: state.selectedMethodId,
                                  onSelect: (id) => context
                                      .read<GuestPaymentMethodPrepaidBloc>()
                                      .add(GuestPaymentMethodSelected(id)),
                                  onPayWithCard: () => context
                                      .read<GuestPaymentMethodPrepaidBloc>()
                                      .add(const GuestPayWithCardPressed()),
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
