// lib/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            // error/snack bar
          },
          child: Column(
            children: [
              // ---------- Scrollable content ----------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: const LoginHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(left: 47,right: 47),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //const SizedBox(height: 12),

                              const SizedBox(height: 48),
                              const LoginPhoneRow(),
                              const SizedBox(height: 20),
                              const LoginPasswordField(),
                              const SizedBox(height: 15),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'forgot password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AuthModuleColors.linkBlue,
                                      height: 1.38,
                                      fontFamily: 'CircularPro',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.08
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // sign in button
                              BlocBuilder<LoginBloc, LoginState>(
                                builder: (context, state) {
                                  final loading = state.status == LoginStatus.loading;

                                  return DefaultButton(
                                      label: 'sign in',
                                      isLoading: loading,
                                      onPressed: (){
                                        context.read<LoginBloc>().add(const LoginSubmitted());
                                      }
                                  );
                                },
                              ),

                              const SizedBox(height: 30),
                              const LoginSocialButtons(),
                              const SizedBox(height: 60),
                              const LoginBottomTexts(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Fixed bottom stripes ----------
              const BottomStripes(),
            ],
          ),
        ),
      ),
    );
  }
}
