import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Usage/postpaid_usage_item.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpage_usage_tile.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpaid_current_plan.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/purchase_addon_button.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_metric_row.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_roaming_widget.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Home/home/data/home_ui_config.dart';

class CurrentPlanTab extends StatelessWidget {
  const CurrentPlanTab({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return Container(
      color: Colors.white,
      child: ListView(
        // padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          // 🔴 Active plan card (reuse your existing widget)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: config.isPostpaid == true
                ? PostpaidCurrentPlan()
                : const PrepaidActivePlanCardWithData(showRenewButton: false),
          ),

          // const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final Uri uri = Uri.parse(
                    'https://www.bealiv.com/fair-use-policy/',
                  );
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw 'Could not launch dialer';
                  }
                },
                child: Text(
                  'fair use policy',
                  style: TextStyle(
                    color: const Color(0xFF645D9C),
                    fontSize: 13,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF645D9C),
                  ),
                ),
              ),
            ),
          ),

          if (config.isPostpaid == true)
            buildUsageSection([
              PostpaidUsageItem(
                title: "data roam free",
                subtitle: "2.4 GB of 15 GB",
                trailingText: "25% used",
                progress: 0.25,
              ),
              PostpaidUsageItem(
                title: "talk mins roam free",
                subtitle: "0 of 800",
                trailingText: "0% used",
                progress: 0.0,
              ),
              PostpaidUsageItem(
                title: "ALIV to ALIV mins",
                subtitle: "unlimited",
                trailingText: "unlimited",
                isUnlimited: true,
                progress: 0,
              ),
              PostpaidUsageItem(
                title: "ALIV to ALIV sms",
                subtitle: "unlimited",
                trailingText: "unlimited",
                isUnlimited: true,
                progress: 0,
              ),
              PostpaidUsageItem(
                title: "ALIV to ALIV mms",
                subtitle: "0 of 800",
                trailingText: "0% used",
                isUnlimited: true,
                progress: 0,
              ),
            ]),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: const _ActiveAddOns(),
            ),

          if (config.isPostpaid == false) const SizedBox(height: 16),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: const _UsageSection(),
            ),

          // const SizedBox(height: 16),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: const PurchaseAddOnButton(),
            ),

          if (config.isPostpaid == false)
            Container(
              // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(color: Color(0xFFF1F2FA)),
              child: const Text(
                'roaming plan',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (config.isPostpaid == false)
            Container(
              // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const _RoamingPlanSection(),
            ),
          if (config.isPostpaid == false) const SizedBox(height: 16),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'roaming data',
                subtitle: '0 of 2 GB',
                progress: 0.0,
                percentUsed: 0,
                gradient: [Color(0xFFFAD4C0), Color(0xFFF2994A)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'local data',
                subtitle: '0 of 0 MB',
                progress: 0.0,
                percentUsed: 0,
                gradient: [Color(0xFFFAD4C0), Color(0xFFF2994A)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'roaming talk mins',
                subtitle: '0 of 0 minutes',
                progress: 0.02,
                percentUsed: 2,
                gradient: [Color(0xFF9ADAF0), Color(0xFF2D9CDB)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'local talk mins',
                subtitle: '0 of 0 minutes',
                progress: 0.02,
                percentUsed: 2,
                gradient: [Color(0xFF9ADAF0), Color(0xFF2D9CDB)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'roaming sms',
                subtitle: '0 of 0 sms',
                progress: 0.55,
                percentUsed: 55,
                gradient: [Color(0xFFC5C3E6), Color(0xFF6B63C5)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: const UsageMetricRow(
                title: 'local sms',
                subtitle: '0 of 0 sms',
                progress: 0.55,
                percentUsed: 55,
                gradient: [Color(0xFFC5C3E6), Color(0xFF6B63C5)],
              ),
            ),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
              child: Text(
                'Roameasy Begins Immediately Bundle\nCalls Unlimited',
                style: TextStyle(
                  color: const Color(0xFF222222),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (config.isPostpaid == false) SizedBox(height: 8),
          if (config.isPostpaid == false)
            Container(
              // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: Color(0xFFF1F2FA)),
              child: SizedBox(height: 20),
            ),
        ],
      ),
    );
  }

  Widget buildUsageSection(List<PostpaidUsageItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      color: Colors.white,
      child: Column(
        children: items.map(
          (e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostpaidUsageTile(item: e),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _ActiveAddOns extends StatelessWidget {
  const _ActiveAddOns();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'active add-ons',
          style: TextStyle(
            color: const Color(0xFF222222),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: const [
            _AddOnChip('voice'),
            _AddOnChip('sms'),
            _AddOnChip('data'),
          ],
        ),
      ],
    );
  }
}

class _AddOnChip extends StatelessWidget {
  final String label;
  const _AddOnChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F4F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFF222222),
          fontSize: 14,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  const _UsageSection();
  static const Color divider = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LimitRow(
          title: 'data',
          subtitle: '2.4 GB of 14 GB',
          percentUsed: 0.25,
          progressColor: Color(0xFFE07A4E),
        ),
        Divider(color: divider),
        SizedBox(
          height: 8,
        ),
        _LimitRow(
          title: 'sms',
          subtitle: 'unlimited Local',
          percentUsed: 100,
          progressColor: Color(0xFF6CB7D4),
        ),
        Divider(color: divider),
        SizedBox(
          height: 8,
        ),
        _LimitRow(
          title: 'talk mins',
          subtitle: 'unlimited Local',
          percentUsed: 100,
          progressColor: Color(0xFF6B63C5),
        ),
        Divider(color: divider),
        SizedBox(
          height: 8,
        ),
        _LimitRow(
          title: 'bonus Data',
          subtitle: 'unlimited WhatsApp Messaging',
          percentUsed: 100,
          progressColor: Color(0xFFBDBDBD),
        ),
        Divider(color: divider),
        SizedBox(
          height: 8,
        ),
        _LimitRow(
          title: 'int’l mins & sms',
          subtitle: '0 of 600',
          percentUsed: 100,
          progressColor: Color(0xFF6B63C5),
        ),
        Divider(color: divider),
        SizedBox(
          height: 8,
        ),
        _LimitRow(
          title: 'mms',
          subtitle: '0 of 60',
          percentUsed: 100,
          progressColor: Color(0xFF6B63C5),
        ),
        Divider(color: divider),
      ],
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percentUsed;
  final Color progressColor;

  const _LimitRow({
    required this.title,
    required this.subtitle,
    required this.percentUsed,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: const Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = 80 * percentUsed.clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // Background
                    Container(
                      height: 6,
                      width: 80,
                      color: config.userType == UserType.postpaid
                          ? const Color(0x26DD3038)
                          : const Color(0x2617B26A).withValues(alpha: 0.2),
                    ),

                    // Gradient progress (width = percentage)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: width.toDouble(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: config.userType == UserType.postpaid
                              ? [Color(0x00DD3038), const Color(0xFFDD3038)]
                              : [
                                  const Color(0x0017B26A),
                                  const Color(0xFF17B26A),
                                ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class UsageRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rightText;
  final double progress;

  const UsageRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rightText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                rightText,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF2994A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoamingPlanSection extends StatelessWidget {
  const _RoamingPlanSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        bottom: 16,
        left: 24,
        right: 24,
      ),
      child: UsageRoamingPlanCard(),
    );
  }
}
