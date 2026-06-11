import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myaliv_mobile_app/resources/widgets/usage_progress_bar.dart';

import '../../../core/appConfig/app_ui_config_cubit.dart';
import '../home/data/home_ui_config.dart';

class RoamingCard extends StatelessWidget {
  final String title;
  final String used;
  final String total;

  /// Used fraction `[0..1]` — matches `UsageCard.progress` semantics. The
  /// bar's filled width encodes **remaining** (`1 - progress`) so a fresh
  /// plan reads full and a depleted plan reads empty. Postpaid color
  /// escalates green → yellow → red as this value grows.
  final double progress;
  final bool isUnlimited;

  const RoamingCard({
    super.key,
    this.title = 'roaming data',
    required this.used,
    required this.total,
    required this.progress,
    this.isUnlimited = false,
  });

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 14,
        //     offset: Offset(0, 6),
        //   ),
        // ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/Rss.svg', height: 18, width: 18),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFFFF6C36),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isUnlimited ? 'unlimited\nlocal' : '$used of\n$total',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF222222),
              fontSize: 16,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'remaining',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF707070),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPostpaid = config.userType == UserType.postpaid;
                final style = resolveUsageBarStyle(
                  isPostpaid: isPostpaid,
                  progressUsed: progress,
                  isUnlimited: isUnlimited,
                );
                final fraction = isUnlimited
                    ? 1.0
                    : (1.0 - progress.clamp(0.0, 1.0));
                final width = 80 * fraction;

                return Stack(
                  children: [
                    Container(height: 6, width: 80, color: style.background),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            style.fill.withValues(alpha: 0),
                            style.fill,
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
