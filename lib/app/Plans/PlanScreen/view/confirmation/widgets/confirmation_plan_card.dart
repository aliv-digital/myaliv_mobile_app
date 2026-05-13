import 'package:flutter/material.dart';

import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

import 'confirmation_plan_card_my_number_content.dart';
import 'confirmation_plan_card_postpaid_content.dart';
import 'confirmation_plan_card_send_topup_content.dart';

class ConfirmationPlanCard extends StatelessWidget {
  final DateTime? date;
  final bool? showBeginOn;
  final HomePlansPostPaidPlanModel? plan;
  final double? topUpAmount;
  final String? recipientPhone;

  const ConfirmationPlanCard({
    super.key,
    this.date,
    this.showBeginOn,
    this.plan,
    this.topUpAmount,
    this.recipientPhone,
  });

  @override
  Widget build(BuildContext context) {
    final hasTopUp = topUpAmount != null;
    final hasRecipient = recipientPhone?.trim().isNotEmpty == true;
    final isSendTopUp = hasTopUp && hasRecipient;
    final isMyNumberTopUp = hasTopUp && !hasRecipient;

    final Widget content;
    if (isSendTopUp) {
      content = ConfirmationPlanCardSendTopUpContent(
        date: date,
        showBeginOn: showBeginOn,
        topUpAmount: topUpAmount!,
        recipientPhone: recipientPhone!,
      );
    } else if (isMyNumberTopUp) {
      content = ConfirmationPlanCardMyNumberContent(
        topUpAmount: topUpAmount!,
      );
    } else {
      content = ConfirmationPlanCardPostpaidContent(
        date: date,
        showBeginOn: showBeginOn,
        plan: plan,
      );
    }

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
      child: content,
    );
  }
}
