import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_session.dart';
import '../../../../resources/extentions/hex_color.dart';
import '../../../../resources/widgets/custom_payment_break_down_card.dart';
import '../../../../router/app_routes.dart';
import '../../../Aliv-Mobile-Guest/guestPurchasePlanComfirmation/theme/guest_purchase_plan_confirmation_theme.dart';
import '../../../Aliv-Mobile/userProfile/topup/prepaid/widgets/pay_from_wallet.dart';

class ConfirmationScreen extends StatefulWidget {
  final bool showBeginOn;
  final DateTime? beginDate;

  const ConfirmationScreen({
    super.key,
    this.showBeginOn = false,
    this.beginDate,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {


  @override
  void initState() {
    super.initState();


  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF645D9C),
          elevation: 0,
          toolbarHeight: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          centerTitle: false,
          title: Text(
            'confirmation and payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: SvgPicture.asset(
                'assets/icons/home.svg',
                color: Colors.white,
              ),
            ),
          ],
        ),

        bottomNavigationBar: Container(
          width: 390,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: const Color(0xFFE1E1E1)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            '\$ 20.00',
                            style: TextStyle(
                              color: const Color(0xFF222222),
                              fontSize: 22,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            'no vat applied',
                            style: TextStyle(
                              color: const Color(0xFF707070),
                              fontSize: 12,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (AppSession.appRoute == 'sendTopUp') {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const PayFromWalletSheet(),
                    );
                  } else {
                    context.push(AppRoutes.guestPaymentMethodScreen);
                  }
                },
                child: Container(
                  width: 170,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF645D9C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Text(
                        'continue',
                        style: TextStyle(
                          color: const Color(0xFFF1F1F8),
                          fontSize: 13,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlanCard(date: widget.beginDate),
                const SizedBox(height: 16),
                if (widget.showBeginOn && widget.beginDate != null)
                  _BeginOnCard(date: widget.beginDate!),

                // if (showBeginOn && beginDate != null) const SizedBox(height: 16),
                const SizedBox(height: 16),
                const _TermsCheckbox(),
                const SizedBox(height: 16),

                CustomPaymentBreakDownCard(
                  backgroundColor: HexColor.fromHex('#645D9C'),
                  items: <CustomPaymentBreakdownLineItem>[
                    CustomPaymentBreakdownLineItem(
                      label: 'sub total',
                      value: '\$ 18.18',
                      // '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                    ),
                    CustomPaymentBreakdownLineItem(
                      label: 'vat',
                      value: '\$ 0.00',
                    ),
                    CustomPaymentBreakdownLineItem(
                      label: 'total',
                      value: '\$ 20.00',
                      //    '\$ ${data.totals.total.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final DateTime? date;

  const _PlanCard({this.date});

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd-MM-yy').format(date ?? DateTime.now());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSession.appRoute == 'sendTopUp'
                    ? Text(
                        'top-up',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : const Text(
                        'Alicia Major',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                const Text(
                  '242-801-1616',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF121212),
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCDC8F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSession.appRoute == 'sendTopUp'
                          ? Text(
                              'top-up prepaid number',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Text(
                              "standalone",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      const SizedBox(height: 6),
                      AppSession.appRoute == 'sendTopUp'
                          ? Text(
                              '242-899-9999',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Text(
                              'travel20 - 7 days',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                      (date != null)
                          ? Text(
                              'begins $formatted',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF707070),
                                fontSize: 10,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const Text(
                              'immediately',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF707070),
                                fontSize: 10,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: AppSession.appRoute == 'sendTopUp'
                      ? Text(
                          '\$ 15.00',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF222222),
                            fontSize: 16,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Text(
                          '\$ 18.18',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF222222),
                            fontSize: 16,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: 20),
                AppSession.appRoute == 'sendTopUp'
                    ? SizedBox(width: 1)
                    : SvgPicture.asset('assets/icons/trash.svg'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeginOnCard extends StatelessWidget {
  final DateTime date;

  const _BeginOnCard({required this.date});

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd-MM-yy').format(date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "begins on | ",
                  style: TextStyle(fontSize: 14),
                ),
                TextSpan(
                  text: formatted,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF707070),
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset('assets/icons/calender_post.svg'),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatefulWidget {
  const _TermsCheckbox();

  @override
  State<_TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<_TermsCheckbox> {
  bool checked = true;
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // ✅ Navigate to Terms
        final uri = Uri.parse('https://www.bealiv.com/terms-of-use/');

        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not open store locator';
        }
      };
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 15,
            height: 15,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: checked
                  ? GuestPurchasePlanConfirmationTheme
                        .termsNoticeCheckboxCheckedFillColor
                  : Colors.transparent,
              border: Border.all(
                width: 1,
                color: GuestPurchasePlanConfirmationTheme
                    .termsNoticeCheckboxBorderColor,
              ),
              borderRadius: BorderRadius.circular(
                GuestPurchasePlanConfirmationTheme.termsNoticeCheckboxRadius,
              ),
            ),
            child: checked
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: GuestPurchasePlanConfirmationTheme
                        .termsNoticeCheckboxIconSize,
                  )
                : null,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "By checking this box, I agree to the ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                TextSpan(
                  recognizer: _termsRecognizer,
                  text: "Terms & Conditions.",
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
