import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../../../../../../core/utils/app_session.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../../../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../../Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bill-receipts/model/guest_pay_bill_receipt_args.dart';
import '../bloc/rev_payment_method_prepaid_bloc.dart';
import '../bloc/rev_payment_method_prepaid_event.dart';
import '../bloc/rev_payment_method_prepaid_state.dart';
import '../repository/rev_payment_method_prepaid_repository_impl.dart';
import '../theme/rev_payment_method_prepaid_theme.dart';
import '../widgets/rev_payment_method_section.dart';

class REVPaymentMethodPrepaidScreen extends StatelessWidget {
  const REVPaymentMethodPrepaidScreen({super.key});

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
      create: (_) => RevPaymentMethodPrepaidBloc(
        repository: RevPaymentMethodPrepaidRepositoryImpl(),
      )..add(const RevPaymentMethodPrepaidStarted()),
      child: const _REVPaymentMethodPrepaidView(),
    );
  }
}

class _REVPaymentMethodPrepaidView extends StatelessWidget {
  const _REVPaymentMethodPrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RevPaymentMethodPrepaidBloc,
        RevPaymentMethodPrepaidState>(
      listenWhen: (p, c) =>
          p.navTarget != c.navTarget || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null && state.status == RevPaymentMethodPrepaidStatus.failure) {

          AppToast.show(
            message: state.errorMessage!.toString(),
            type: ToastType.error
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(state.errorMessage!)),
          // );
        }

        if (state.navTarget != RevPaymentMethodNavTarget.none) {
          // TODO: handle navigation when you need
          // if (state.navTarget == RevPaymentMethodNavTarget.addCard) { ... }
          // if (state.navTarget == RevPaymentMethodNavTarget.paid) { ... }

          context
              .read<RevPaymentMethodPrepaidBloc>()
              .add(const RevPaymentNavConsumed());
        }
      },
      builder: (context, state) {
        final isLoading = state.status == RevPaymentMethodPrepaidStatus.loading;
        final isSubmitting =
            state.status == RevPaymentMethodPrepaidStatus.submitting;

        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: RevPaymentMethodPrepaidTheme.bg,
            bottomNavigationBar: DefaultBottomPayBar(
              amountText: state.amountText,
              isVatExclusive: true,//state.vatNote.trim().toLowerCase() == 'no vat applied',
              isButtonEnabled: state.isPayNowEnabled,
              isLoading: isSubmitting,
              buttonColor: RevPaymentMethodPrepaidTheme.payBtnBg,
              onPayNow: () {
                context
                    .read<RevPaymentMethodPrepaidBloc>()
                    .add(const RevPayNowPressed());
                AppSession.appRoute = 'postpaidPayment';
                context.push(AppRoutes.guestPayBillReceipt,extra:
                  GuestPayBillReceiptArgs(
                    serviceName: 'REV',
                    identifierLabel: 'phone no.',
                    identifierValue: '242-801-0000',
                    amount: 200.00,
                    dateText: 'Mar 22, 2023',
                    timeText: '07:30 am',
                  ),
                );
              }
            ),
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: RevPaymentMethodPrepaidTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: 'payment',
                      height: RevPaymentMethodPrepaidTheme.appBarHeight,
                      backgroundColor: RevPaymentMethodPrepaidTheme.appBarBg,
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
                        padding: const EdgeInsets.fromLTRB(
                          RevPaymentMethodPrepaidTheme.screenHorizontalPadding,
                          RevPaymentMethodPrepaidTheme.screenTopPadding,
                          RevPaymentMethodPrepaidTheme.screenHorizontalPadding,
                          RevPaymentMethodPrepaidTheme.screenBottomPadding,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : RevPaymentMethodSection(
                                  methods: state.methods,
                                  selectedId: state.selectedMethodId,
                                  onSelect: (id) => context
                                      .read<RevPaymentMethodPrepaidBloc>()
                                      .add(RevPaymentMethodSelected(id)),
                                  onPayWithCard: () => context
                                      .read<RevPaymentMethodPrepaidBloc>()
                                      .add(const RevPayWithCardPressed()),
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
