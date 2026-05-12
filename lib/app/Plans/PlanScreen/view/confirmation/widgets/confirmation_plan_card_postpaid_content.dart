import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../utils/plan_display.dart';

class ConfirmationPlanCardPostpaidContent extends StatelessWidget {
  final DateTime? date;
  final bool? showBeginOn;
  final HomePlansPostPaidPlanModel? plan;

  const ConfirmationPlanCardPostpaidContent({
    super.key,
    this.date,
    this.showBeginOn,
    this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final accountState = instance<AccountInfoCubit>().state;
    final userName = accountDisplayName(accountState);
    final userNumber = accountUsername(accountState);
    final title = planTitleFor(plan);
    final price = planPriceFor(plan);
    final typeLabel = planTypeLabelFor(plan);
    final hasBeginDate = showBeginOn == true && date != null;
    final beginText = hasBeginDate
        ? 'begins ${DateFormat('dd-MM-yy').format(date!)}'
        : 'begins immediately';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                userNumber,
                style: const TextStyle(
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
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      beginText,
                      style: const TextStyle(
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
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(AssetConstant.trashIconSVG),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
