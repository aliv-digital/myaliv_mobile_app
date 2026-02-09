// lib/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../repository/auth_repository.dart';
import '../theme/login_theme.dart';
import '../widgets/login_bottom_stripes.dart';
import '../widgets/login_bottom_texts.dart';
import '../widgets/login_header.dart';
import '../widgets/login_password_field.dart';
import '../widgets/login_phone_row.dart';
import '../widgets/login_social_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(repository: LoginRepository()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  // BottomStripes height fixed na hole, eta constant hishebe estimate kore rekho.
  // Better: BottomStripes er vitore exact height const kore expose kora (e.g. BottomStripes.kHeight)
  static const double _bottomStripeHeight = BottomStripes.kHeight;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Keyboard উঠলেও body resize হবে না (BottomStripes নড়বে না)
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
             // context.go(AppRoutes.home);
            }
          },
          child: Stack(
            children: [
              // ----------- Main content (scrollable) -----------
              Padding(
                // ✅ stripes overlay করবে, তাই নিচে space reserve করে দিলাম
                padding: const EdgeInsets.only(bottom: _bottomStripeHeight),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(
                      child: LoginHeader(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 47, right: 47),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 36),
                            const LoginPhoneRow(),
                            const SizedBox(height: 14),
                            const LoginPasswordField(),
                            const SizedBox(height: 10),
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                final hasError = state.status == LoginStatus.failure && state.errorMessage != null;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Visibility(
                                          visible: hasError,
                                          maintainSize: true,
                                          maintainState: true,
                                          maintainAnimation: true,
                                          child: const Text(
                                            'invalid credentials!',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AuthModuleColors.errorRed,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        context.push(AppRoutes.forgetPassword);
                                      },
                                      child: Text(
                                        'forgot password?',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AuthModuleColors.linkBlue,
                                          height: 1.38,
                                          fontFamily: 'CircularPro',
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: -0.08,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 15),

                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                final loading = state.status == LoginStatus.loading;
                                return DefaultButton(
                                  label: 'sign in',
                                  isLoading: loading,
                                  height: 48,
                                  onPressed: () {
                                    context.read<LoginBloc>().add(const LoginSubmitted());
                                    context.push(AppRoutes.loginOtp);
                                  },
                                );
                              },
                            ),

                           // const SizedBox(height: 24),
                            const LoginSocialButtons(),
                            const SizedBox(height: 34),
                            const SizedBox(height: 220),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ----------- Bottom stripes (always pinned) -----------
              const Positioned(
                left: 0,
                right: 0,
                bottom: 112,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 41),
                  child: LoginBottomTexts(),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomStripes(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
