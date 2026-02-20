import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../../../../../../router/app_routes.dart';
import '../bloc/profile_postpaid_bloc.dart';
import '../bloc/profile_postpaid_event.dart';
import '../bloc/profile_postpaid_state.dart';
import '../repository/profile_postpaid_repository.dart';
import '../theme/profile_postpaid_theme.dart';
import '../widgets/profile_menu_item_tile.dart';

class ProfilePostpaidScreen extends StatelessWidget {
  const ProfilePostpaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ProfilePostpaidRepository(),
      child: BlocProvider(
        create: (ctx) => ProfilePostpaidBloc(
          repository: ctx.read<ProfilePostpaidRepository>(),
        )..add(const ProfilePostpaidStarted()),
        child: const _ProfilePostpaidView(),
      ),
    );
  }
}

class _ProfilePostpaidView extends StatelessWidget {
  const _ProfilePostpaidView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfilePostpaidBloc, ProfilePostpaidState>(
      listenWhen: (p, c) =>
      p.backRequestId != c.backRequestId ||
          p.openRouteRequestId != c.openRouteRequestId,
      listener: (context, state) {
        if (state.backRequestId > 0) {
          Navigator.of(context).maybePop();
        }

        if (state.openRouteRequestId > 0 && (state.routeToOpen?.isNotEmpty ?? false)) {
          // go_router use করলে:
          // context.push(state.routeToOpen!);
          // ignore: avoid_print
          print('Navigate to: ${state.routeToOpen}');
        }
      },
      child: Scaffold(
        backgroundColor: ProfilePostpaidTheme.bg,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  title: 'profile',
                  onBack: () => context.read<ProfilePostpaidBloc>().add(const ProfilePostpaidBackPressed()),
                  showBackArrow: true,
                    onHomeTap: () => context.go(AppRoutes.home)

                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<ProfilePostpaidBloc, ProfilePostpaidState>(
                  builder: (context, state) {
                    if (state.status == ProfilePostpaidStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return Column(
                      children: [
                        const Divider(height: 1, thickness: 1, color: ProfilePostpaidTheme.divider),
                        ...state.items.map((item) {
                          return ProfilePostpaidMenuItemTile(
                            title: item.title,
                            enabled: item.enabled,
                            onTap: () => context.read<ProfilePostpaidBloc>().add(ProfilePostpaidItemPressed(item)),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
