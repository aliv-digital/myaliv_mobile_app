import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import '../../../../router/app_routes.dart';
import '../../login/widgets/login_privacy_policy_link.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import '../repository/forgetpassword_repository.dart';
import '../theme/forget_password_theme.dart';
import '../widgets/forgetpass_header.dart';
import '../widgets/forget_password_keyboard_done_toolbar.dart';
import '../widgets/forgetpass_phone_row.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordBloc(repository: ForgetPasswordRepository()),
      child: const _ForgetPasswordKeyboardView(),
    );
  }
}

class _ForgetPasswordKeyboardView extends StatefulWidget {
  const _ForgetPasswordKeyboardView();

  @override
  State<_ForgetPasswordKeyboardView> createState() =>
      _ForgetPasswordKeyboardViewState();
}

class _ForgetPasswordKeyboardViewState
    extends State<_ForgetPasswordKeyboardView> {
  final FocusNode _phoneFocusNode = FocusNode(
    debugLabel: 'forgetPasswordPhone',
  );

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ForgetPasswordKeyboardDoneToolbar(
      phoneFocusNode: _phoneFocusNode,
      child: _ForgetPasswordScreenView(phoneFocusNode: _phoneFocusNode),
    );
  }
}

class _ForgetPasswordScreenView extends StatelessWidget {
  const _ForgetPasswordScreenView({required this.phoneFocusNode});

  final FocusNode phoneFocusNode;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: ForgetPasswordColors.pageBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return StripedScaffold(
      backgroundColor: ForgetPasswordColors.pageBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == ForgetPasswordStatus.success) {
              context.push(
                AppRoutes.forgetPasswordOtp,
                extra: LoginOtpRouteArgs(
                  mfaToken: state.mfaToken,
                  phoneNumber: state.phone,
                  apiPhoneNumber: state.apiPhoneNumber,
                ),
              );
            }

            if (state.status == ForgetPasswordStatus.failure &&
                state.errorMessage != null) {
              AppToast.show(
                message: state.errorMessage!,
                type: ToastType.error,
              );
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverToBoxAdapter(child: ForgetPasswordHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: ForgetPasswordPaddings.pageHorizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ForgetPasswordPhoneRow(focusNode: phoneFocusNode),
                      const SizedBox(
                        height: ForgetPasswordSizes.phoneToSendGap,
                      ),
                      BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                        buildWhen: (prev, curr) => prev.status != curr.status,
                        builder: (context, state) {
                          return DefaultButton(
                            label: 'send',
                            isLoading:
                                state.status == ForgetPasswordStatus.loading,
                            textStyle: ForgetPasswordTheme.sendButton,
                            onPressed: () {
                              context.read<ForgetPasswordBloc>().add(
                                const ForgetPasswordSubmitted(),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(
                        height: ForgetPasswordSizes.sendToTermsGap,
                      ),
                      const Center(child: LoginPrivacyPolicyLink()),
                    ],
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
