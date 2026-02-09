import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/guest_pay_bill_receipt_bloc.dart';
import '../bloc/guest_pay_bill_receipt_event.dart';
import '../bloc/guest_pay_bill_receipt_state.dart';
import '../repository/guest_pay_bill_receipt_repository.dart';
import '../theme/theme.dart';
import '../widgets/receipt_success_card.dart';
import '../widgets/payment_failure.dart';

class GuestPayBillReceiptScreen extends StatelessWidget {
  const GuestPayBillReceiptScreen({
    super.key,
    required this.phoneNumber,
    required this.amount,
    required this.dateText,
    required this.timeText,
    this.paymentMethod = 'credit card',
  });

  final String phoneNumber;
  final double amount;
  final String dateText;
  final String timeText;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final receiptData = GuestPayBillReceiptData(
      leftType: 'service',
      rightType: 'REV',
      dateText: dateText,
      timeText: timeText,
      phoneNumber: phoneNumber,
      paymentMethod: paymentMethod,
      amount: amount,
    );

    return RepositoryProvider(
      create: (_) => GuestPayBillReceiptRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPayBillReceiptBloc(
          repository: ctx.read<GuestPayBillReceiptRepository>(),
        )..add(GuestPayBillReceiptStarted(receiptData)),
        child: const _GuestPayBillReceiptView(),
      ),
    );
  }
}

class _GuestPayBillReceiptView extends StatelessWidget {
  const _GuestPayBillReceiptView();

  static const _purple = Color(0xFF645D9C);
  static const _bg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestPayBillReceiptBloc, GuestPayBillReceiptState>(
      listenWhen: (p, c) => p.backHomeRequestId != c.backHomeRequestId,
      listener: (context, state) {
        if (state.backHomeRequestId > 0) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  showBackArrow: false,
                  title: 'my receipt',
                  onBack: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 29,
                    bottom: 30,
                  ),
                  child: BlocBuilder<GuestPayBillReceiptBloc, GuestPayBillReceiptState>(
                    builder: (context, state) {
                      final data = state.data;
                      if (data == null) return const SizedBox.shrink();

                      return ReceiptSuccessCard(
                        data: data,
                        onBackHome: () {},
                        pageBackground: GuestPayBillReceiptTheme.circleBackground,
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 29,
                        bottom: 30,
                      ),
                      child: BlocBuilder<GuestPayBillReceiptBloc, GuestPayBillReceiptState>(
                        builder: (context, state) {
                          final data = state.data;
                          if (data == null) return const SizedBox.shrink();

                          return PaymentFailedTicket(
                            phone: "242-300-2548",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
