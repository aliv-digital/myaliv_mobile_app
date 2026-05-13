import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/pay_from_wallet.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'confirmation/utils/confirmation_formatters.dart';
import 'confirmation/widgets/confirmation_app_bar.dart';
import 'confirmation/widgets/confirmation_begin_on_card.dart';
import 'confirmation/widgets/confirmation_bottom_bar.dart';
import 'confirmation/widgets/confirmation_breakdown.dart';
import 'confirmation/widgets/confirmation_plan_card.dart';
import 'confirmation/widgets/confirmation_terms_checkbox.dart';

class ConfirmationScreen extends StatefulWidget {
  final bool showBeginOn;
  final DateTime? beginDate;
  final HomePlansPostPaidPlanModel? plan;
  final double? topUpAmount;
  final String? recipientPhone;

  const ConfirmationScreen({
    super.key,
    this.showBeginOn = false,
    this.beginDate,
    this.plan,
    this.topUpAmount,
    this.recipientPhone,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  HomePlansPostPaidPlanModel? _selectedPostpaidPlan;
  DateTime? _selectedBeginDate;
  bool _termsAccepted = true;
  String _promoCode = '';

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
    final isMyNumberTopUp =
        widget.topUpAmount != null && widget.recipientPhone == null;
    if (isMyNumberTopUp) {
      final amountParam = widget.topUpAmount!.toStringAsFixed(2);
      context.push(
        '${AppRoutes.topUpPaymentPrepaidScreen}?amount=$amountParam',
      );
      return;
    }
    if (widget.topUpAmount != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PayFromWalletSheet(amount: widget.topUpAmount!),
      );
      return;
    }
    context.push(AppRoutes.guestPaymentMethodScreen);
  }

  @override
  Widget build(BuildContext context) {
    final isSendTopUp = widget.topUpAmount != null;
    final isMyNumberTopUp = isSendTopUp && widget.recipientPhone == null;
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
                  recipientPhone: widget.recipientPhone,
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
                ConfirmationBreakdown(
                  subTotalText: subTotalText,
                  vatText: formatConfirmationCurrency(vat),
                  totalText: totalText,
                  promoValue: isMyNumberTopUp ? _promoCode : null,
                  onPromoChanged: (v) => setState(() => _promoCode = v),
                  onPromoApply: () => FocusScope.of(context).unfocus(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
