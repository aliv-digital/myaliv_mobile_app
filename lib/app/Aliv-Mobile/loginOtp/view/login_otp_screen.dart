import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../login/widgets/login_bottom_stripes.dart';
import '../bloc/login_otp_bloc.dart';
import '../bloc/login_otp_state.dart';
import '../repository/login_otp_repository.dart';
import '../theme/login_otp_theme.dart';
import '../widgets/otp_header.dart';
import '../widgets/otp_code_fields.dart';
import '../widgets/otp_bottom_actions.dart';

class LoginOtpScreen extends StatelessWidget {
  const LoginOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginOtpBloc(repository: LoginOtpRepository()),
      child: const _LoginOtpView(),
    );
  }
}

class _LoginOtpView extends StatelessWidget {
  const _LoginOtpView();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: LoginOtpColors.screenBackground,

      // ✅ Default behavior back (keyboard উঠলে body resize হবে + auto scroll works)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<LoginOtpBloc, LoginOtpState>(
          listener: (context, state) {
            if (state.status == LoginOtpStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: LoginOtpTheme.snackBarText,
                  ),
                ),
              );
            }
          },
          child: Stack(
            children: [
              Column(
                children: [
                  // ---------- Scrollable content ----------
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        const SliverToBoxAdapter(child: OtpHeader()),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: LoginOtpPaddings.contentHorizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                SizedBox(height: LoginOtpSizes.contentTopGap),
                                OtpCodeFields(),
                                SizedBox(height: LoginOtpSizes.otpToBottomActionsGap),
                                OtpBottomActions(),
                                SizedBox(height: LoginOtpSizes.contentBottomGap),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Bottom stripes will VANISH when keyboard opens (no moving up)
                  AnimatedSwitcher(
                    duration: LoginOtpMotion.stripeSwitcherDuration,
                    switchInCurve: LoginOtpMotion.stripeSwitcherInCurve,
                    switchOutCurve: LoginOtpMotion.stripeSwitcherOutCurve,
                    child: keyboardOpen ? const SizedBox.shrink() : const BottomStripes(),
                  ),
                ],
              ),
              if (!keyboardOpen)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: BottomStripes.kHeight + LoginOtpSizes.changePhoneBottomOffset,
                  child: _ChangePhoneNumberAction(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePhoneNumberAction extends StatelessWidget {
  const _ChangePhoneNumberAction();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Text(
        'change phone number',
        textAlign: TextAlign.center,
        style: LoginOtpTheme.changePhoneText,
      ),
    );
  }
}
