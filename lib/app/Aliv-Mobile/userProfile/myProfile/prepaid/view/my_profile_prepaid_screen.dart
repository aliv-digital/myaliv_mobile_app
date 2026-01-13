import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/my_profile_prepaid_bloc.dart';
import '../bloc/my_profile_prepaid_event.dart';
import '../bloc/my_profile_prepaid_state.dart';
import '../repository/my_profile_prepaid_repository.dart';
import '../theme/my_profile_prepaid_theme.dart';
import '../widgets/my_profile_prepaid_action_tile.dart';
import '../widgets/my_profile_prepaid_device_card.dart';
import '../widgets/my_profile_prepaid_header.dart';
import '../widgets/my_profile_prepaid_info_card.dart';

class MyProfilePrepaidScreen extends StatelessWidget {
  const MyProfilePrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocProvider(
      create: (_) => MyProfilePrepaidBloc(MyProfilePrepaidRepository())
        ..add(const MyProfilePrepaidStarted()),
      child: const _MyProfilePrepaidView(),
    );
  }
}

class _MyProfilePrepaidView extends StatelessWidget {
  const _MyProfilePrepaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyProfilePrepaidTheme.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<MyProfilePrepaidBloc, MyProfilePrepaidState>(
          listenWhen: (p, c) =>
          p.navRequestId != c.navRequestId || p.navAction != c.navAction,
          listener: (context, state) {
            switch (state.navAction) {
              case MyProfilePrepaidNavAction.back:
                Navigator.of(context).maybePop();
                break;
              case MyProfilePrepaidNavAction.home:
                Navigator.of(context).popUntil((r) => r.isFirst);
                break;
              case MyProfilePrepaidNavAction.editEmail:
                debugPrint("edit email");
                context.push(AppRoutes.editEmailPrepaidScreen);
                break;
              case MyProfilePrepaidNavAction.changePassword:
                debugPrint("change password");
                context.push(AppRoutes.enterPassWordPrepaidScreen);
                break;
              case MyProfilePrepaidNavAction.none:
                break;
            }
          },
          child: Column(
            children: [
              // ---------- Scrollable content ----------
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    // Appbar (already done)
                    SliverToBoxAdapter(
                      child: DefaultAppBar(
                        title: 'my profile',
                        showHome: true,
                        onHomeTap: () {
                          context
                              .read<MyProfilePrepaidBloc>()
                              .add(const MyProfilePrepaidHomePressed());
                        },
                      ),
                    ),

                    BlocBuilder<MyProfilePrepaidBloc, MyProfilePrepaidState>(
                      builder: (context, state) {
                        if (state.status == MyProfilePrepaidStatus.loading ||
                            state.status == MyProfilePrepaidStatus.initial) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (state.status == MyProfilePrepaidStatus.failure) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'Something went wrong',
                                style: MyProfilePrepaidTheme.textBodyBold,
                              ),
                            ),
                          );
                        }

                        final data = state.data!;

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                const BoxConstraints(maxWidth: 420),
                                child: Column(
                                  children: [
                                    // ✅ Header (avatar + name + status pill)
                                    MyProfilePrepaidHeader(
                                      avatarLetter: data.avatarLetter,
                                      fullName: data.fullName,
                                      statusLabel: data.statusLabel,
                                    ),
                                    const SizedBox(height: 24),

                                    MyProfilePrepaidInfoCard(
                                      phone: data.phone,
                                      activeOn: data.activeOn,
                                      email: data.email,
                                    ),
                                    const SizedBox(height: 16),

                                    MyProfilePrepaidDeviceCard(
                                      title: data.deviceTitle,
                                      deviceModel: data.deviceModel,
                                    ),
                                    const SizedBox(height: 16),

                                    MyProfilePrepaidActionTile(
                                      iconPath: AssetConstant.emailIconSVG,
                                      title: 'edit email',
                                      onTap: () => context
                                          .read<MyProfilePrepaidBloc>()
                                          .add(const MyProfilePrepaidEditEmailPressed()),
                                    ),
                                    const SizedBox(height: 16),

                                    MyProfilePrepaidActionTile(
                                      iconPath: AssetConstant.passwordIconSVG,
                                      title: 'change password',
                                      onTap: () => context
                                          .read<MyProfilePrepaidBloc>()
                                          .add(const MyProfilePrepaidChangePasswordPressed()),
                                    ),

                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // fixed bottom stripes (already ok)
              const BottomStripes(),
            ],
          ),
        ),
      ),
    );
  }
}
