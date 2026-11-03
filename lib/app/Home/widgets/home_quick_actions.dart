import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/action_tile.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeQuickActions extends StatelessWidget {
  final HomeUiConfig config;
  final VoidCallback? onOpenAlivDeals;

  const HomeQuickActions({
    super.key,
    required this.config,
    this.onOpenAlivDeals,
  });

  Future<void> _defaultOpenAlivDeals() async {
    const urlString = 'https://www.bealiv.com/deals/';
    final uri = Uri.parse(urlString);
    if (instance.isRegistered<AnalyticsService>()) {
      await instance<AnalyticsService>().logOutboundClick(
        linkDestination: 'deals',
        linkUrl: urlString,
      );
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open store locator';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (config.isRestricted) {
      return _buildRestrictedQuickActions(context);
    }
    return _buildStandardQuickActions(context);
  }

  Widget _buildRestrictedQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileHeight = (constraints.maxWidth - 20) / 3;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: tileHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context
                              .read<AppUiConfigCubit>()
                              .showFuturePlansView();
                          context.go(AppRoutes.usage);
                        },
                        child: const ActionTile(
                          'assets/icons/ListStarQuick.svg',
                          'future\nplans',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.push(AppRoutes.myProfilePrepaidScreen);
                        },
                        child: const ActionTile(
                          'assets/icons/At.svg',
                          'update\nemail',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.push(AppRoutes.referFriendPrepaidScreen);
                        },
                        child: const ActionTile(
                          'assets/icons/UsersThree.svg',
                          'refer a friend',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: tileHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onOpenAlivDeals ?? _defaultOpenAlivDeals,
                        child: const ActionTile(
                          'assets/icons/aliv_quick.svg',
                          'ALIV deals',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.push(AppRoutes.callSupportScreen);
                        },
                        child: const ActionTile(
                          'assets/icons/headphone.svg',
                          'help & support',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStandardQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.go(AppRoutes.plans);
            },
            child: const ActionTile(
              'assets/icons/ListStarQuick.svg',
              'buy\nplans',
            ),
          ),
          if (config.userType.isPostpaid)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<AppUiConfigCubit>().showMyLimitsView();
                context.go(AppRoutes.usage);
              },
              child: const ActionTile(
                'assets/icons/SortDescending.svg',
                'update\ncredit limit',
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push(AppRoutes.addOrEditCardsPrepaidScreen);
            },
            child: const ActionTile(
              'assets/icons/add_credit_card.svg',
              'add\ncredit card',
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push(AppRoutes.myProfilePrepaidScreen);
            },
            child: const ActionTile('assets/icons/At.svg', 'update\nemail'),
          ),
          if (config.userType.isPrepaid)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.push(AppRoutes.referFriendPrepaidScreen);
              },
              child: const ActionTile(
                'assets/icons/UsersThree.svg',
                'refer a friend',
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onOpenAlivDeals ?? _defaultOpenAlivDeals,
            child: const ActionTile(
              'assets/icons/aliv_quick.svg',
              'ALIV deals',
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push(AppRoutes.callSupportScreen);
            },
            child: const ActionTile(
              'assets/icons/headphone.svg',
              'help & support',
            ),
          ),
        ],
      ),
    );
  }
}
