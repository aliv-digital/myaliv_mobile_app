import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verification_coordinator.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/app/common/verification/account_action_otp_navigation.dart';
import 'package:myaliv_mobile_app/core/appConfig/active_device.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';

import '../../../../../../resources/widgets/top_toast.dart';
import '../../../../../../router/app_routes.dart';

import '../bloc/change_password_prepaid_bloc.dart';
import '../bloc/change_password_prepaid_event.dart';
import '../bloc/change_password_prepaid_state.dart';
import '../repository/change_password_prepaid_repository.dart';
import '../theme/change_password_prepaid_theme.dart';
import '../widgets/change_password_prepaid_header_text.dart';
import '../widgets/change_password_prepaid_password_field.dart';
import '../widgets/change_password_prepaid_submit_button.dart';

class ChangePasswordPrepaidScreen extends StatefulWidget {
  const ChangePasswordPrepaidScreen({super.key});

  @override
  State<ChangePasswordPrepaidScreen> createState() =>
      _ChangePasswordPrepaidScreenState();
}

class _ChangePasswordPrepaidScreenState
    extends State<ChangePasswordPrepaidScreen> {
  late final ChangePasswordPrepaidBloc _bloc;
  late final AuthManager _auth;
  late final ActionVerificationCoordinator<ProtectedAccountAction>
  _verification;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _sessionCheck;
  TokenSession? _verifiedSession;
  bool _journeyActive = true;
  bool _leaving = false;

  bool get _sessionCurrent =>
      _journeyActive &&
      _verifiedSession != null &&
      identical(_auth.currentSession, _verifiedSession) &&
      !_verifiedSession!.accessExpired &&
      !_verifiedSession!.refreshExpired;

  @override
  void initState() {
    super.initState();
    _auth = instance<AuthManager>();
    final account = instance<AccountInfoCubit>();
    final devices = instance<DeviceLimitsCubit>();
    final initialAccount = account.state.accountInfo;
    final identity = (initialAccount?.idAcc, initialAccount?.username);
    // Snapshot the active device id so a mid-flow switch invalidates the
    // in-progress change-password journey.
    final deviceId = ActiveDevice.id();
    _verification = ActionVerificationCoordinator<ProtectedAccountAction>();
    final phone = (initialAccount?.phoneNumber.isNotEmpty == true)
        ? initialAccount!.phoneNumber
        : initialAccount?.primaryPhoneNumber;
    _bloc = ChangePasswordPrepaidBloc(
      ChangePasswordPrepaidRepository(),
      phoneNumber: phone,
      verifyAction: (attemptId) async {
        final result = await requestAccountActionOtp(
          context: context,
          coordinator: _verification,
          purpose: ProtectedAccountAction.changePassword,
          attemptId: attemptId,
          isOwnerActive: () => _journeyActive,
        );
        if (mounted && _journeyActive && result != null) {
          _verifiedSession = _auth.currentSession;
        }
        return result;
      },
      isAuthorizationCurrent: () =>
          mounted &&
          _sessionCurrent &&
          ModalRoute.of(context)?.isCurrent == true,
      cancelVerification: _verification.cancel,
    );
    _subscriptions.add(
      account.stream.listen((state) {
        final next = state.accountInfo;
        if ((next?.idAcc, next?.username) != identity) {
          _invalidate();
        }
      }),
    );
    _subscriptions.add(
      devices.stream.listen((_) {
        if (ActiveDevice.id() != deviceId) {
          _invalidate();
        }
      }),
    );
    // AuthManager has no session stream. Check while this route owns the
    // journey, and synchronously check again before consuming authorization.
    _sessionCheck = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_verifiedSession != null && !_sessionCurrent) {
        _invalidate();
      }
      _leaveIfCancelled();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bloc.add(const ChangePasswordPrepaidStarted());
      }
    });
  }

  void _invalidate() {
    _journeyActive = false;
    // An open OTP screen remains cancellable; its attempt cannot succeed.
    // Waiting for its return preserves the existing Back/navigation contract.
    if (_bloc.state.status != ChangePasswordPrepaidStatus.initial &&
        _bloc.state.status != ChangePasswordPrepaidStatus.verifying &&
        _bloc.state.status !=
            ChangePasswordPrepaidStatus.verificationCancelled) {
      _bloc.add(const ChangePasswordPrepaidAuthorizationInvalidated());
    }
  }

  void _leaveIfCancelled() {
    if (!mounted ||
        _leaving ||
        _bloc.state.status !=
            ChangePasswordPrepaidStatus.verificationCancelled ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    _leaving = true;
    _journeyActive = false;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _journeyActive = false;
    _sessionCheck?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _bloc,
    child: BlocConsumer<ChangePasswordPrepaidBloc, ChangePasswordPrepaidState>(
      listener: (context, state) {
        if (state.status == ChangePasswordPrepaidStatus.verificationCancelled) {
          if (state.errorMessage != null) {
            AppToast.show(message: state.errorMessage!, type: ToastType.error);
          }
          _leaveIfCancelled();
        }
      },
      builder: (context, state) {
        if (state.status != ChangePasswordPrepaidStatus.initial &&
            state.status != ChangePasswordPrepaidStatus.verifying &&
            state.status != ChangePasswordPrepaidStatus.verificationCancelled &&
            !_sessionCurrent) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _invalidate();
            }
          });
          return const StripedScaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }
        if (state.status == ChangePasswordPrepaidStatus.initial ||
            state.status == ChangePasswordPrepaidStatus.verifying ||
            state.status == ChangePasswordPrepaidStatus.verificationCancelled) {
          return const StripedScaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }
        return const _ChangePasswordPrepaidView();
      },
    ),
  );
}

class _ChangePasswordPrepaidView extends StatelessWidget {
  const _ChangePasswordPrepaidView();

  @override
  Widget build(BuildContext context) {
    return StripedScaffold(
      backgroundColor: ChangePasswordPrepaidTheme.bg,

      // ✅ keep default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        top: false,
        child: BlocListener<ChangePasswordPrepaidBloc, ChangePasswordPrepaidState>(
          listenWhen: (p, c) =>
              p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == ChangePasswordPrepaidStatus.success) {
              AppToast.show(
                message: 'Your password has been changed successfully.',
                type: ToastType.success,
              );
              context.go(AppRoutes.home);
            }

            if (state.status == ChangePasswordPrepaidStatus.failure &&
                (state.errorMessage ?? '').isNotEmpty) {
              AppToast.show(
                message: state.errorMessage ?? 'failed to update password',
                type: ToastType.error,
              );
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: DefaultAppBar(
                  title: 'change password',
                  showHome: false,
                  onBack: () {
                    context.pop();
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 18),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ChangePasswordPrepaidHeaderText(),
                          const SizedBox(height: 20),
                          BlocBuilder<
                            ChangePasswordPrepaidBloc,
                            ChangePasswordPrepaidState
                          >(
                            buildWhen: (p, c) =>
                                p.newPassword != c.newPassword ||
                                p.obscureNew != c.obscureNew ||
                                p.newPasswordError != c.newPasswordError,
                            builder: (context, state) {
                              return ChangePasswordPrepaidPasswordField(
                                hint: 'new password',
                                value: state.newPassword,
                                obscure: state.obscureNew,
                                errorText: state.newPasswordError,
                                onChanged: (v) => context
                                    .read<ChangePasswordPrepaidBloc>()
                                    .add(ChangePasswordPrepaidNewChanged(v)),
                                onToggle: () => context
                                    .read<ChangePasswordPrepaidBloc>()
                                    .add(
                                      const ChangePasswordPrepaidToggleNewVisibility(),
                                    ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<
                            ChangePasswordPrepaidBloc,
                            ChangePasswordPrepaidState
                          >(
                            buildWhen: (p, c) =>
                                p.confirmPassword != c.confirmPassword ||
                                p.obscureConfirm != c.obscureConfirm ||
                                p.confirmPasswordError !=
                                    c.confirmPasswordError,
                            builder: (context, state) {
                              return ChangePasswordPrepaidPasswordField(
                                hint: 'confirm new password',
                                value: state.confirmPassword,
                                obscure: state.obscureConfirm,
                                errorText: state.confirmPasswordError,
                                onChanged: (v) => context
                                    .read<ChangePasswordPrepaidBloc>()
                                    .add(
                                      ChangePasswordPrepaidConfirmChanged(v),
                                    ),
                                onToggle: () => context
                                    .read<ChangePasswordPrepaidBloc>()
                                    .add(
                                      const ChangePasswordPrepaidToggleConfirmVisibility(),
                                    ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child:
                                BlocBuilder<
                                  ChangePasswordPrepaidBloc,
                                  ChangePasswordPrepaidState
                                >(
                                  buildWhen: (p, c) =>
                                      p.status != c.status ||
                                      p.isValid != c.isValid,
                                  builder: (context, state) {
                                    final isLoading =
                                        state.status ==
                                            ChangePasswordPrepaidStatus
                                                .verifying ||
                                        state.status ==
                                            ChangePasswordPrepaidStatus
                                                .submitting;

                                    return ChangePasswordPrepaidSubmitButton(
                                      label: 'change password',
                                      enabled: !isLoading,
                                      isLoading: isLoading,
                                      onTap: () {
                                        context
                                            .read<ChangePasswordPrepaidBloc>()
                                            .add(
                                              const ChangePasswordPrepaidSubmitPressed(),
                                            );
                                      },
                                    );
                                  },
                                ),
                          ),
                          const SizedBox(height: 260),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
