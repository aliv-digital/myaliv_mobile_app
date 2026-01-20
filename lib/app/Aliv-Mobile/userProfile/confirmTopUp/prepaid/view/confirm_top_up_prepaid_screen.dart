import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/confirm_top_up_prepaid_bloc.dart';
import '../bloc/confirm_top_up_prepaid_event.dart';
import '../bloc/confirm_top_up_prepaid_state.dart';
import '../repository/confirm_top_up_prepaid_repository.dart';
import '../theme/confirm_top_up_prepaid_theme.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/confirm_top_up_header_card.dart';
import '../widgets/promo_summary_ticket.dart';


class ConfirmTopUpPrepaidScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final double amount;

  const ConfirmTopUpPrepaidScreen({
    super.key,
    this.customerName = 'Jade Turnquest',
    this.customerPhone = '242-801-1616',
    this.amount = 15.00,
  });

  @override
  State<ConfirmTopUpPrepaidScreen> createState() => _ConfirmTopUpPrepaidScreenState();
}

class _ConfirmTopUpPrepaidScreenState extends State<ConfirmTopUpPrepaidScreen> {
  late final TextEditingController _promoController;

  @override
  void initState() {
    super.initState();
    _promoController = TextEditingController();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfirmTopUpPrepaidBloc(ConfirmTopUpPrepaidRepositoryImpl())
        ..add(ConfirmTopUpStarted(
          customerName: widget.customerName,
          customerPhone: widget.customerPhone,
          amount: widget.amount,
        )),
      child: BlocConsumer<ConfirmTopUpPrepaidBloc, ConfirmTopUpPrepaidState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage || p.status != c.status,
        listener: (context, state) {
          final msg = state.errorMessage;
          if (msg != null && msg.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          }
          if (state.status == ConfirmTopUpStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top up confirmed')));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ConfirmTopUpPrepaidTheme.background,
            appBar: _appBar(context),
            bottomNavigationBar: ConfirmTopUpBottomBar(
              total: state.breakdown.total,
              vatExclusive: state.breakdown.vatExclusive,
              isLoading: state.status == ConfirmTopUpStatus.submitting,
              onContinue: () {
                context.read<ConfirmTopUpPrepaidBloc>().add(const ContinuePressed());
                context.push(AppRoutes.topUpPaymentPrepaidScreen);
              },
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConfirmTopUpHeaderCard(
                      customerName: state.customerName,
                      customerPhone: state.customerPhone,
                      amount: state.amount,
                    ),
                    const SizedBox(height: 14),

                    _termsLine(context),

                    const SizedBox(height: 16),

                    PromoSummaryTicket(
                      controller: _promoController,
                      onChanged: (v) => context.read<ConfirmTopUpPrepaidBloc>().add(PromoCodeChanged(v)),
                      onApply: () => context.read<ConfirmTopUpPrepaidBloc>().add(const PromoCodeApplied()),
                      subTotal: state.breakdown.subTotal,
                      vat: state.breakdown.vat,
                      total: state.breakdown.total,
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
    return AppBar(
      backgroundColor: ConfirmTopUpPrepaidTheme.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'confirmation',
        style: ConfirmTopUpPrepaidTheme.titleMd(context).copyWith(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white),
          onPressed: () {
            // TODO: integrate GoRouter home route
          },
        ),
      ],
    );
  }

  Widget _termsLine(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: ConfirmTopUpPrepaidTheme.bodySm(context).copyWith(color: ConfirmTopUpPrepaidTheme.textPrimary),
        children: [
          const TextSpan(text: 'By pressing “continue” you agree to the '),
          TextSpan(
            text: 'Terms &\nConditions.',
            style: ConfirmTopUpPrepaidTheme.link(context),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.read<ConfirmTopUpPrepaidBloc>().add(const TermsPressed());
                // TODO: navigate to Terms screen
              },
          ),
        ],
      ),
    );
  }
}
