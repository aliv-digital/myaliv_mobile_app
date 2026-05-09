import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_session.dart';
import '../../../../resources/extentions/dateformatter.dart';
import '../../../../resources/extentions/hex_color.dart';
import '../../../../resources/widgets/custom_payment_break_down_card.dart';
import '../../../../router/app_routes.dart';
import '../../../Aliv-Mobile-Guest/guestPurchasePlanComfirmation/theme/guest_purchase_plan_confirmation_theme.dart';
import '../../../Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import '../../../Aliv-Mobile/account-information/cubit/account_info_state.dart';
import '../../../Aliv-Mobile/userProfile/topup/prepaid/widgets/pay_from_wallet.dart';
import '../../../Home/best-plans/best_plan_injection.dart';
import '../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'start_plan_bottom_sheet.dart';

class ConfirmationScreen extends StatefulWidget {
  final bool showBeginOn;
  final DateTime? beginDate;
  final HomePlansPostPaidPlanModel? plan;

  const ConfirmationScreen({
    super.key,
    this.showBeginOn = false,
    this.beginDate,
    this.plan,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  HomePlansPostPaidPlanModel? _selectedPostpaidPlan;
  DateTime? _selectedBeginDate;
  bool _termsAccepted = true;

  @override
  void initState() {
    super.initState();
    _selectedPostpaidPlan = widget.plan;
    _selectedBeginDate = widget.beginDate;
  }

  @override
  void didUpdateWidget(covariant ConfirmationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      _selectedPostpaidPlan = widget.plan;
    }
    if (oldWidget.beginDate != widget.beginDate) {
      _selectedBeginDate = widget.beginDate;
    }
  }

  void _termsAcceptedChanged(bool isAccepted) {
    setState(() {
      _termsAccepted = isAccepted;
    });
  }

  void _beginDateChanged(DateTime date) {
    setState(() {
      _selectedBeginDate = date;
    });
  }

  void _continuePressed() {
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
  }

  @override
  Widget build(BuildContext context) {
    final subTotal = _selectedPostpaidPlan?.planAmount ?? 18.18;
    final vat = _selectedPostpaidPlan?.vatAmount ?? 0.0;
    final total = _selectedPostpaidPlan?.planAmountWithVat ?? 20.00;
    final vatLabel = vat <= 0
        ? 'no vat applied'
        : ' vat applied'; //${_formatConfirmationCurrency(vat)}
    final continueButtonColor =
        _termsAccepted ? const Color(0xFF645D9C) : const Color(0xFFC8C5DA);
    final continueTextColor =
        _termsAccepted ? const Color(0xFFF1F1F8) : const Color(0xFF707070);

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
            InkWell(
              onTap: () {
                context.go(AppRoutes.home);
              },
              child: GestureDetector(
                onTap: () {
                  context.go(AppRoutes.home);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: SvgPicture.asset(
                    'assets/icons/home.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
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
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            _formatConfirmationCurrency(total),
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
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            vatLabel,
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
                onTap: _termsAccepted ? _continuePressed : null,
                child: Container(
                  width: 170,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: ShapeDecoration(
                    color: continueButtonColor,
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
                          color: continueTextColor,
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
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
                _PlanCard(
                  date: _selectedBeginDate,
                  showBeginOn: widget.showBeginOn,
                  plan: _selectedPostpaidPlan,
                ),
                const SizedBox(height: 16),
                if (widget.showBeginOn && _selectedBeginDate != null)
                  _BeginOnCard(
                    date: _selectedBeginDate!,
                    onDateChanged: _beginDateChanged,
                  ),

                // if (showBeginOn && beginDate != null) const SizedBox(height: 16),
                const SizedBox(height: 16),
                _TermsCheckbox(
                  isChecked: _termsAccepted,
                  onChanged: _termsAcceptedChanged,
                ),
                const SizedBox(height: 16),

                CustomPaymentBreakDownCard(
                  backgroundColor: HexColor.fromHex('#645D9C'),
                  items: <CustomPaymentBreakdownLineItem>[
                    CustomPaymentBreakdownLineItem(
                      label: 'sub total',
                      value: _formatConfirmationCurrency(subTotal),
                      // '\$ ${data.totals.subTotal.toStringAsFixed(2)}',
                    ),
                    CustomPaymentBreakdownLineItem(
                      label: 'vat',
                      value: _formatConfirmationCurrency(vat),
                    ),
                    CustomPaymentBreakdownLineItem(
                      label: 'total',
                      value: _formatConfirmationCurrency(total),
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

String _formatConfirmationCurrency(double value) {
  return '\$ ${value.toStringAsFixed(2)}';
}

class _PlanCard extends StatelessWidget {
  final DateTime? date;
  final bool? showBeginOn;
  final HomePlansPostPaidPlanModel? plan;

  const _PlanCard({this.date, this.showBeginOn, this.plan});

  String _selectedPlanTitle() {
    final selectedPlan = plan;
    if (selectedPlan == null) {
      return 'travel20 - 7 days';
    }

    final planName = selectedPlan.planName.trim();
    final title = planName.isEmpty ? 'selected plan' : planName;

    final duration = selectedPlan.durationText.trim();
    if (duration.isEmpty || duration == '--') {
      return title;
    }
    // for now we will skip to show duration with title,
    // later we may add this if client asks

    return '$title - $duration';
    //return title;
  }

  String _selectedPlanPrice() {
    final selectedPlan = plan;
    if (selectedPlan == null) {
      return '\$ --.--';
    }

    return _formatConfirmationCurrency(selectedPlan.planAmount);
  }

  String _selectedPlanTypeLabel() {
    final planTypeCode = plan?.planType.trim().toUpperCase();

    switch (planTypeCode) {
      case 'A':
        return 'standalone';
      case 'S':
        return 'secondary';
      case 'P':
        return 'primary';
      default:
        return 'plan';
    }
  }

  String _accountDisplayName(AccountInfoState accountState) {
    final fullName = accountState.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    return _nameFromEmail(accountState.email);
  }

  String _accountUsername(AccountInfoState accountState) {
    final username = accountState.accountInfo?.username.trim() ?? '';
    return username.isEmpty ? '--' : username;
  }

  String _nameFromEmail(String? email) {
    final normalizedEmail = email?.trim() ?? '';
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'User';
    }

    return normalizedEmail.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd-MM-yy').format(date ?? DateTime.now());
    final selectedPlanTitle = _selectedPlanTitle();
    final selectedPlanPrice = _selectedPlanPrice();
    final selectedPlanType = _selectedPlanTypeLabel();
    final accountState = instance<AccountInfoCubit>().state;
    final userName = _accountDisplayName(accountState);
    final userNumber = _accountUsername(accountState);

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
                    : Text(
                        userName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                Text(
                  userNumber,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF121212),
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
                              selectedPlanType,
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
                              selectedPlanTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      (showBeginOn == true && date != null)
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
                              'begins immediately',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF707070),
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
                          selectedPlanPrice,
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
                    : InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: SvgPicture.asset(AssetConstant.trashIconSVG),
                      ),
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
  final ValueChanged<DateTime> onDateChanged;

  const _BeginOnCard({
    required this.date,
    required this.onDateChanged,
  });

  Future<void> _openCalendarPickerSheet(BuildContext context) async {
    // Reuse the same calendar bottom sheet used by StartPlanBottomSheet so
    // both screens keep identical date-picking behavior and styling.
    final pickedDate = await showStartPlanCalendarPickerSheet(
      context,
      initialDate: date,
    );

    if (pickedDate == null) return;
    onDateChanged(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    final formatted = formatWithOrdinal(date);
    //DateFormat('dd-MM-yy').format(date);

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
          InkWell(
            onTap: () => _openCalendarPickerSheet(context),
            child: SvgPicture.asset('assets/icons/calender_post.svg'),
          ),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({
    required this.isChecked,
    required this.onChanged,
  });

  @override
  State<_TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<_TermsCheckbox> {
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
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onChanged(!widget.isChecked),
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.isChecked
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
              child: widget.isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: GuestPurchasePlanConfirmationTheme
                          .termsNoticeCheckboxIconSize,
                    )
                  : null,
            ),
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
                    decorationColor: Color(0xFF645D9C),
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
