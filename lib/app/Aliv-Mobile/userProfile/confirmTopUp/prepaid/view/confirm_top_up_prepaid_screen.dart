import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _promoController = TextEditingController();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // ✅ Navigate to Terms
        final uri = Uri.parse('https://www.bealiv.com/terms-of-use/');

        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not open store locator';
        }
      };

  }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _promoController = TextEditingController();
  // }

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
            // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top up confirmed')));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ConfirmTopUpPrepaidTheme.background,
            appBar: _appBar(context),
            bottomNavigationBar: ConfirmTopUpBottomBar(
              total: state.breakdown.total,
              vatExclusive: false,
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
      elevation: 0,centerTitle: false,toolbarHeight: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      title: Text(
        'confirmation & payment',
        style: ConfirmTopUpPrepaidTheme.titleMd(context).copyWith(color: Colors.white),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: IconButton(
            icon:  SvgPicture.asset('assets/icons/home.svg',color: Colors.white,),
            onPressed: () {
              // TODO: integrate GoRouter home route
              context.go(AppRoutes.home);
            },
          ),
        ),
      ],
    );
  }

  Widget _termsLine(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon(Icons.check_box_outlined),

        Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: SvgPicture.asset('assets/icons/Checkbox=On.svg'),
        ),
        SizedBox(width: 10,),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'By checking this box, I agree to the ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                TextSpan(
                  text: 'Terms & Conditions.',
                  recognizer: _termsRecognizer,

                  style: TextStyle(
                    color: const Color(0xFF645D9C),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
