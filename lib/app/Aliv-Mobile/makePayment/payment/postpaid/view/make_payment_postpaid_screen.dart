import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../resources/widgets/default_app_bar.dart';
import '../bloc/make_payment_postpaid_bloc.dart';
import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';
import '../repository/make_payment_postpaid_repository_impl.dart';
import '../theme/make_payment_postpaid_theme.dart';
import '../widgets/mp_bottom_bar.dart';
import '../widgets/mp_payment_due_card.dart';
import '../widgets/mp_payment_method_section.dart';
import '../widgets/mp_terms_checkbox.dart';

class MakePaymentPostPaidScreen extends StatelessWidget {
  const MakePaymentPostPaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MakePaymentPostPaidBloc(
        repository: MakePaymentPostPaidRepositoryImpl(),
      )..add(const MakePaymentPostPaidStarted()),
      child: const _MakePaymentPostPaidView(),
    );
  }
}

class _MakePaymentPostPaidView extends StatelessWidget {
  const _MakePaymentPostPaidView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MakePaymentPostPaidBloc, MakePaymentPostPaidState>(
      listenWhen: (p, c) => p.navTarget != c.navTarget,
      listener: (context, state) {
        if (state.navTarget == MpNavTarget.next) {
          context.read<MakePaymentPostPaidBloc>().add(const MpNavConsumed());
        }
      },
      builder: (context, state) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: MakePaymentPostPaidTheme.bg,
            bottomNavigationBar: MpBottomBar(
              amountText: state.bottomAmount,
              subtitle: state.bottomSubtitle,
              enabled: state.canPayNow,
              onPayNow: () {
                context.read<MakePaymentPostPaidBloc>().add(
                  const MpPayNowPressed(),
                );
              },
            ),
            body: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: MakePaymentPostPaidTheme.appBarHeight,
                    child: DefaultAppBar(
                      title: state.title,
                      height: MakePaymentPostPaidTheme.appBarHeight,
                      backgroundColor: MakePaymentPostPaidTheme.appBarBg,
                      showBackArrow: true,
                      showHome: true,
                      onHomeTap: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(29, 24, 29, 22),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MpPaymentDueCard(
                                amountText: state.paymentDueAmount,
                                selectedOption: state.amountOption,
                                customAmount: state.customAmount,
                                onOptionChanged: (option) {
                                  context.read<MakePaymentPostPaidBloc>().add(
                                    MpAmountOptionChanged(option),
                                  );
                                },
                                onCustomAmountChanged: (value) {
                                  context.read<MakePaymentPostPaidBloc>().add(
                                    MpCustomAmountChanged(value),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              MpTermsCheckbox(
                                value: state.termsAccepted,
                                onChanged: (value) {
                                  context.read<MakePaymentPostPaidBloc>().add(
                                    MpTermsToggled(value),
                                  );
                                },
                                onTermsTap: () {},
                              ),
                              const SizedBox(height: 17),
                              MpPaymentMethodSection(
                                methods: state.methods,
                                selectedIndex: state.selectedMethodIndex,
                                onSelect: (index) {
                                  context.read<MakePaymentPostPaidBloc>().add(
                                    MpPaymentMethodSelected(index),
                                  );
                                },
                                onAddCard: () {},
                              ),
                              const SizedBox(height: 90),
                            ],
                          ),
                        ),
                      ),
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
