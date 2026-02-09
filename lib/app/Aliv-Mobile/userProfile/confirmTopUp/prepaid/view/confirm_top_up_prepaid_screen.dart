import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
                padding: const EdgeInsets.fromLTRB(29, 24, 29, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConfirmTopUpHeaderCard(
                      customerName: state.customerName,
                      customerPhone: state.customerPhone,
                      amount: state.amount,
                    ),
                    const SizedBox(height: 18),

                    _termsLine(context),

                    const SizedBox(height: 38),

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
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      title: Text(
        'confirmation',
        style: ConfirmTopUpPrepaidTheme.titleMd(context).copyWith(color: Colors.white),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: IconButton(
            icon:  SvgPicture.asset('assets/icons/home.svg',color: Colors.white,),
            onPressed: () {
              // TODO: integrate GoRouter home route
            },
          ),
        ),
      ],
    );
  }

  Widget _termsLine(BuildContext context) {
    return SizedBox(
      width: 332,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'By pressing “continue” you agree to the ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Circular Pro',
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
            TextSpan(
              text: 'Terms & Conditions.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Circular Pro',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
