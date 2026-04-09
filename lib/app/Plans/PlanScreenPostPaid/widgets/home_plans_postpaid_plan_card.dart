import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../models/home_plans_postpaid_plan_model.dart';

class HomePlansPostPaidPlanCard extends StatelessWidget {
  const HomePlansPostPaidPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onPurchaseNow,
  });

  final HomePlansPostPaidPlanModel plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onPurchaseNow;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(8, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              plan.planName,
                              style: const TextStyle(
                                fontFamily: 'CircularPro',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onToggle,
                            child: AnimatedRotation(
                              turns: expanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.durationText,
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 10,
                          color: Color(0xFF707070),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                SvgPicture.asset(
                    AssetConstant.wifiIconSVG), //'assets/icons/Rss.svg'
                const SizedBox(width: 4),
                Text(
                  plan.primaryDataLabel,
                  style: TextStyle(
                    color: Color(0xFFFF6C36),
                    fontSize: 18,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  plan.primaryDataValue,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'CircularPro',
                  ),
                ),
                const Spacer(),
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
                    '\$ ${plan.planAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'CircularPro',
                    ),
                  ),
                ),
              ],
            ),
            if (expanded) ...<Widget>[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Text(
                  plan.descriptionText,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.38,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onToggle,
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Color(0xFFF1F1F8)),
                    ),
                    child: Text(
                      expanded ? 'hide details' : 'view details',
                      style: const TextStyle(
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF645D9C),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPurchaseNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF645D9C),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'purchase now',
                      style: TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF1F1F8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
