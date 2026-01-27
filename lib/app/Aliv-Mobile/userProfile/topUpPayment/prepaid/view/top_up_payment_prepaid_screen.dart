import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/widgets/pay_with_card_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/widgets/payment_method_tile.dart';

import '../bloc/top_up_payment_prepaid_bloc.dart';
import '../bloc/top_up_payment_prepaid_event.dart';
import '../bloc/top_up_payment_prepaid_state.dart';
import '../repository/top_up_payment_prepaid_repository.dart';
import '../theme/top_up_payment_prepaid_theme.dart';
import '../widgets/bottom_pay_bar.dart';
import '../widgets/payment_method_card.dart';


class TopUpPaymentPrepaidScreen extends StatelessWidget {
  const TopUpPaymentPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopUpPaymentPrepaidBloc(TopUpPaymentPrepaidRepositoryImpl())
        ..add(const TopUpPaymentStarted()),
      child: BlocConsumer<TopUpPaymentPrepaidBloc, TopUpPaymentPrepaidState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage || p.status != c.status,
        listener: (context, state) {
          final msg = state.errorMessage;
          if (msg != null && msg.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          }
          if (state.status == TopUpPaymentStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: TopUpPaymentPrepaidTheme.background,
            appBar: _appBar(context),
            bottomNavigationBar: BottomPayBar(
              total: state.summary.total,
              vatInclusive: state.summary.vatInclusive,
              isLoading: state.status == TopUpPaymentStatus.paying,
              onPayNow: () => context.read<TopUpPaymentPrepaidBloc>().add(const PayNowPressed()),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PaymentMethodCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('payment method', style: TopUpPaymentPrepaidTheme.labelSm(context)),
                          const SizedBox(height: 10),

                          ...state.methods.map((m) {
                            final selected = state.selectedMethodId == m.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: PaymentMethodTile(
                                logoAsset: m.logoAsset,
                                title: m.title,
                                subtitle: 'expiry ${m.expiry}',
                                isSelected: selected,
                                onTap: () => context.read<TopUpPaymentPrepaidBloc>().add(PaymentMethodSelected(m.id)),
                              ),
                            );
                          }),

                          PayWithCardTile(
                            onTap: () {
                              context.read<TopUpPaymentPrepaidBloc>().add(const PayWithCardPressed());
                              // TODO: Navigate to add card screen (GoRouter)
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    // If your project has DefaultAppBar, replace this with it.
    return AppBar(
      backgroundColor: TopUpPaymentPrepaidTheme.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'payment',
        style: TopUpPaymentPrepaidTheme.titleMd(context).copyWith(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white),
          onPressed: () {
            // TODO: GoRouter home
          },
        ),
      ],
    );
  }
}
