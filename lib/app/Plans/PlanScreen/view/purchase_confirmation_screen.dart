import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/pay_from_wallet.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'confirmation/utils/confirmation_formatters.dart';
import 'confirmation/widgets/confirmation_app_bar.dart';
import 'confirmation/widgets/confirmation_begin_on_card.dart';
import 'confirmation/widgets/confirmation_bottom_bar.dart';
import 'confirmation/widgets/confirmation_plan_card.dart';
import 'confirmation/widgets/confirmation_terms_checkbox.dart';

class ConfirmationScreen extends StatefulWidget {
  final bool showBeginOn;
  final DateTime? beginDate;
  final HomePlansPostPaidPlanModel? plan;
  final double? topUpAmount;

  const ConfirmationScreen({
    super.key,
    this.showBeginOn = false,
    this.beginDate,
    this.plan,
    this.topUpAmount,
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

  void _continuePressed() {
    if (widget.topUpAmount != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PayFromWalletSheet(amount: widget.topUpAmount!),
      );
    } else {
      context.push(AppRoutes.guestPaymentMethodScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSendTopUp = widget.topUpAmount != null;
    final topUpAmountText = formatConfirmationCurrency(widget.topUpAmount ?? 0);
    final subTotal = _selectedPostpaidPlan?.planAmount ?? 18.18;
    final vat = _selectedPostpaidPlan?.vatAmount ?? 0.0;
    final total = _selectedPostpaidPlan?.planAmountWithVat ?? 20.00;
    final subTotalText = isSendTopUp
        ? topUpAmountText
        : formatConfirmationCurrency(subTotal);
    final totalText = isSendTopUp
        ? topUpAmountText
        : formatConfirmationCurrency(total);
    final vatLabel = isSendTopUp || vat <= 0
        ? 'no vat applied'
        : ' vat applied';

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2FA),
        appBar: ConfirmationAppBar(
          onBack: () => Navigator.of(context).maybePop(),
          onHome: () => context.go(AppRoutes.home),
        ),
        bottomNavigationBar: ConfirmationBottomBar(
          totalText: totalText,
          vatLabel: vatLabel,
          enabled: _termsAccepted,
          onContinue: _continuePressed,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConfirmationPlanCard(
                  date: _selectedBeginDate,
                  showBeginOn: widget.showBeginOn,
                  plan: _selectedPostpaidPlan,
                  topUpAmount: widget.topUpAmount,
                ),
                const SizedBox(height: 16),
                if (widget.showBeginOn && _selectedBeginDate != null)
                  ConfirmationBeginOnCard(
                    date: _selectedBeginDate!,
                    onDateChanged: (date) =>
                        setState(() => _selectedBeginDate = date),
                  ),
                const SizedBox(height: 16),
                ConfirmationTermsCheckbox(
                  isChecked: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v),
                ),
                const SizedBox(height: 16),
                CustomPaymentBreakDownCard(
                  backgroundColor: HexColor.fromHex('#645D9C'),
                  items: [
                    CustomPaymentBreakdownLineItem(
                      label: 'sub total',
                      value: subTotalText,
                    ),
                    CustomPaymentBreakdownLineItem(
                      label: 'vat',
                      value: formatConfirmationCurrency(vat),
                    ),
                    CustomPaymentBreakdownLineItem(
                      label: 'total',
                      value: totalText,
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
