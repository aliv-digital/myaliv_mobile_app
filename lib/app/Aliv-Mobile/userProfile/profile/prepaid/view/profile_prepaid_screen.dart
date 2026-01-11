import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/profile_prepaid_bloc.dart';
import '../bloc/profile_prepaid_event.dart';
import '../bloc/profile_prepaid_state.dart';
import '../repository/profile_prepaid_repository.dart';
import '../theme/profile_prepaid_theme.dart';
import '../widgets/profile_menu_item_tile.dart';

class ProfilePrepaidScreen extends StatelessWidget {
  const ProfilePrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ProfilePrepaidRepository(),
      child: BlocProvider(
        create: (ctx) => ProfilePrepaidBloc(
          repository: ctx.read<ProfilePrepaidRepository>(),
        )..add(const ProfilePrepaidStarted()),
        child: const _ProfilePrepaidView(),
      ),
    );
  }
}

class _ProfilePrepaidView extends StatelessWidget {
  const _ProfilePrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfilePrepaidBloc, ProfilePrepaidState>(
      listenWhen: (p, c) =>
      p.backRequestId != c.backRequestId ||
          p.openRouteRequestId != c.openRouteRequestId,
      listener: (context, state) {
        if (state.backRequestId > 0) {
          Navigator.of(context).maybePop();
        }

        // Future navigation (route set করলে কাজ করবে)
        if (state.openRouteRequestId > 0 && (state.routeToOpen?.isNotEmpty ?? false)) {
          // go_router use করলে এখানে:
          // context.push(state.routeToOpen!);
          // আপাতত placeholder:
          // ignore: avoid_print
          print('Navigate to: ${state.routeToOpen}');
        }
      },
      child: Scaffold(
        backgroundColor: ProfilePrepaidTheme.bg,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  title: 'profile',
                  onBack: () => context.read<ProfilePrepaidBloc>().add(const ProfilePrepaidBackPressed()),
                  showBackArrow: true,
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<ProfilePrepaidBloc, ProfilePrepaidState>(
                  builder: (context, state) {
                    if (state.status == ProfilePrepaidStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return Column(
                      children: [
                        const Divider(height: 1, thickness: 1, color: ProfilePrepaidTheme.divider),
                        ...state.items.map((item) {
                          return ProfileMenuItemTile(
                            title: item.title,
                            enabled: item.enabled,
                            onTap: () => context.read<ProfilePrepaidBloc>().add(ProfilePrepaidItemPressed(item)),
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
