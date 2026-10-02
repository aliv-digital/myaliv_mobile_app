import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_session.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
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
        create: (ctx) =>
            ProfilePrepaidBloc(repository: ctx.read<ProfilePrepaidRepository>())
              ..add(const ProfilePrepaidStarted()),
        child: const _ProfilePrepaidView(),
      ),
    );
  }
}

class _ProfilePrepaidView extends StatefulWidget {
  const _ProfilePrepaidView();

  @override
  State<_ProfilePrepaidView> createState() => _ProfilePrepaidViewState();
}

class _ProfilePrepaidViewState extends State<_ProfilePrepaidView> {
  bool _requestingCallLogsChallenge = false;

  Future<void> _openCallLogs() async {
    if (_requestingCallLogsChallenge) return;

    if (instance<CallLogsVerificationSession>().isVerified) {
      context.push('${AppRoutes.callLogs}?tab=call_logs');
      return;
    }

    setState(() => _requestingCallLogsChallenge = true);
    try {
      final challenge = await instance<CallLogsVerificationRepository>()
          .requestChallenge();
      if (!mounted) return;

      context.push(
        AppRoutes.callLogsOtp,
        extra: CallLogsOtpRouteArgs(
          mfaToken: challenge.mfaToken,
          apiPhoneNumber: challenge.apiPhoneNumber,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppToast.show(message: error.toString(), type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _requestingCallLogsChallenge = false);
      }
    }
  }

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

        if (state.openRouteRequestId > 0 &&
            (state.routeToOpen?.isNotEmpty ?? false)) {
          // placeholder
          // ignore: avoid_print
          print('Navigate to: ${state.routeToOpen}');
        }
      },
      child: StripedScaffold(
        backgroundColor: ProfilePrepaidTheme.bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  title: 'profile',
                  onBack: () => context.read<ProfilePrepaidBloc>().add(
                    const ProfilePrepaidBackPressed(),
                  ),
                  showBackArrow: true,
                  onHomeTap: () => context.go(AppRoutes.home),
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

                    return Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        children: [
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: ProfilePrepaidTheme.divider,
                          ),
                          ...state.items.map((item) {
                            return ProfileMenuItemTile(
                              title: item.title,
                              enabled: item.enabled,
                              isTapEnabled:
                                  item.id != 'call_logs' ||
                                  !_requestingCallLogsChallenge,
                              trailing:
                                  item.id == 'call_logs' &&
                                      _requestingCallLogsChallenge
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: Center(
                                        child: SizedBox.square(
                                          dimension: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                                ProfilePrepaidTheme.textBlack,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () async {
                                if (item.id == 'my_profile') {
                                  context.push(
                                    AppRoutes.myProfilePrepaidScreen,
                                  );
                                }
                                if (item.id == 'my_plans') {
                                  context
                                      .read<AppUiConfigCubit>()
                                      .showCurrentPlansView();
                                  context.go(AppRoutes.usage);
                                }

                                if (item.id == 'call_logs') {
                                  if (_requestingCallLogsChallenge) return;
                                  context.read<ProfilePrepaidBloc>().add(
                                    ProfilePrepaidItemPressed(item),
                                  );
                                  await _openCallLogs();
                                  return;
                                }
                                if (item.id == 'rewards') {
                                  context.push(AppRoutes.rewardPrepaidScreen);
                                }
                                context.read<ProfilePrepaidBloc>().add(
                                  ProfilePrepaidItemPressed(item),
                                );
                              },
                            );
                          }),
                        ],
                      ),
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
