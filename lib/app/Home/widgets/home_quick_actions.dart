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
    final uri = Uri.parse('https://www.bealiv.com/deals/');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open store locator';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          if (!config.isRestricted)
            GestureDetector(
              onTap: () {
                context.go(AppRoutes.plans);
              },
              child: const ActionTile(
                'assets/icons/ListStarQuick.svg',
                'buy\nplans',
              ),
            ),
          if (config.userType.isPostpaid && !config.isRestricted)
            GestureDetector(
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
            onTap: () {
              context.push(AppRoutes.addOrEditCardsPrepaidScreen);
            },
            child: const ActionTile(
              'assets/icons/add_credit_card.svg',
              'add\ncredit card',
            ),
          ),
          GestureDetector(
            onTap: () {
              context.push(AppRoutes.myProfilePrepaidScreen);
            },
            child: const ActionTile('assets/icons/At.svg', 'update\nemail'),
          ),
          if (config.userType.isPrepaid)
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.referFriendPrepaidScreen);
              },
              child: const ActionTile(
                'assets/icons/UsersThree.svg',
                'refer a friend',
              ),
            ),
          GestureDetector(
            onTap: onOpenAlivDeals ?? _defaultOpenAlivDeals,
            child: const ActionTile(
              'assets/icons/aliv_quick.svg',
              'ALIV deals',
            ),
          ),
          GestureDetector(
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
