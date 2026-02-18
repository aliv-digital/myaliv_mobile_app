import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/current_plan_active_card.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/purchase_addon_button.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_metric_row.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_roaming_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentPlanTab extends StatelessWidget {
  const CurrentPlanTab({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        // padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          // 🔴 Active plan card (reuse your existing widget)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: const PrepaidCurrentPlanActivePlanCard(showRenewButton: false),
          ),

          // const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 20, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final Uri uri = Uri.parse('https://www.bealiv.com/fair-use-policy/');
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
                  ),
                )
              ),
            ),
          ),

          // const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: const _ActiveAddOns(),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: const _UsageSection(),
          ),

          // const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: const PurchaseAddOnButton(),
          ),

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
          Container(
            // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: const _RoamingPlanSection(),
          ),
          const SizedBox(height: 16),

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
          SizedBox(height: 8,),
          Container(
            // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: Color(0xFFF1F2FA)),
            child: SizedBox(height: 20,)
          ),
        ],
      ),
    );
  }
}

class _ActiveAddOns extends StatelessWidget {
  const _ActiveAddOns();

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'active add-ons',
          style: TextStyle(
            color: const Color(0xFF222222),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF645D9C)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: const Color(0xFF645D9C),
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
      children: const [
        _LimitRow(
          title: 'data',
          subtitle: '2.4 GB of 14 GB',
          percentUsed: 25,
          progressColor: Color(0xFFE07A4E),
        ),
        Divider(color: divider),

        _LimitRow(
          title: 'sms',
          subtitle: 'unlimited Local',
          percentUsed: 0,
          progressColor: Color(0xFF6CB7D4),
        ),
        Divider(color: divider),

        _LimitRow(
          title: 'talk mins',
          subtitle: 'unlimited Local',
          percentUsed: 0,
          progressColor: Color(0xFF6B63C5),
        ),
        Divider(color: divider),

        _LimitRow(
          title: 'bonus Data',
          subtitle: 'unlimited WhatsApp Messaging',
          percentUsed: 0,
          progressColor: Color(0xFFBDBDBD),
        ),
        Divider(color: divider),

        _LimitRow(
          title: 'int’l mins & sms',
          subtitle: '0 of 600',
          percentUsed: 55,
          progressColor: Color(0xFF6B63C5),
        ),
        Divider(color: divider),

        _LimitRow(
          title: 'mms',
          subtitle: '0 of 60',
          percentUsed: 55,
          progressColor: Color(0xFF6B63C5),
        ),
        Divider(color: divider),

        // UsageRow(
        //   title: 'data',
        //   subtitle: '2.4 GB of 14 GB',
        //   rightText: '25% used',
        //   progress: 0.25,
        // ),
        // UsageRow(
        //   title: 'sms',
        //   subtitle: 'unlimited local',
        //   rightText: 'unlimited',
        //   progress: 1,
        // ),
        // UsageRow(
        //   title: 'talk mins',
        //   subtitle: 'unlimited local',
        //   rightText: 'unlimited',
        //   progress: 1,
        // ),
        // UsageRow(
        //   title: 'bonus data',
        //   subtitle: 'unlimited whatsapp messaging',
        //   rightText: 'unlimited',
        //   progress: 1,
        // ),
      ],
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int percentUsed;
  final Color progressColor;

  const _LimitRow({
    required this.title,
    required this.subtitle,
    required this.percentUsed,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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

          // RIGHT PROGRESS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                child:
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(6),
                    //   child: LinearProgressIndicator(
                    //     value: percentUsed / 100,
                    //     minHeight: 6,
                    //     backgroundColor: progressColor.withOpacity(0.2),
                    //     valueColor: AlwaysStoppedAnimation(progressColor),
                    //   ),
                    // ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = 120 * percentUsed.clamp(0.0, 1.0);

                          return Stack(
                            children: [
                              // Background
                              Container(
                                height: 6,
                                width: 120,
                                color: Color(0x3F808080).withOpacity(0.2),
                              ),

                              // Gradient progress (width = percentage)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 6,
                                width: width.toDouble(),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: title == 'data'
                                        ? [Color(0xFFF0D7CE), Color(0xFFE94408)]
                                        : title == 'local data'
                                        ? [
                                            const Color(0xFF97E3F8),
                                            const Color(0xFF00627D),
                                          ]
                                        : title == 'local talk mins' ||
                                              title == 'int’l talk mins'
                                        ? [
                                            const Color(0xFFCCC7F8),
                                            const Color(0xFF1F1B41),
                                          ]
                                        : [
                                            const Color(0x3F808080),
                                            const Color(0x3F808080),
                                          ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentUsed% used',
                style: const TextStyle(
                  color: const Color(0xFF707070),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
