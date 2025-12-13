import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../../login/widgets/login_bottom_stripes.dart';
import '../bloc/create_password_bloc.dart';
import '../bloc/create_password_event.dart';
import '../bloc/create_password_state.dart';
import '../repository/create_password_repository.dart';
import '../widgets/create_password_header.dart';
import '../widgets/password_input.dart';

class CreatePasswordScreen extends StatelessWidget {
  const CreatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePasswordBloc(repository: CreatePasswordRepository()),
      child: const _CreatePasswordView(),
    );
  }
}

class _CreatePasswordView extends StatelessWidget {
  const _CreatePasswordView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<CreatePasswordBloc, CreatePasswordState>(
          listenWhen: (p, c) =>
          p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if(state.status == CreatePasswordStatus.success){
            }
            // এখানে তোমার snackbar logic থাকবে (invalid/failure/success)
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
                    const SliverToBoxAdapter(
                      child: CreatePasswordHeader(),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.only(right: 54,left: 40),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 39),

                            // password
                            BlocBuilder<CreatePasswordBloc, CreatePasswordState>(
                              buildWhen: (p, c) => p.obscurePassword != c.obscurePassword || p.password != c.password,
                              builder: (context, state) {
                                return PasswordInput(
                                  hint: 'password',
                                  obscureText: state.obscurePassword,
                                  onChanged: (v) => context.read<CreatePasswordBloc>().add(PasswordChanged(v)),
                                  onToggle: () {
                                    context.read<CreatePasswordBloc>().add(const TogglePasswordVisibility());
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // confirm
                            BlocBuilder<CreatePasswordBloc, CreatePasswordState>(
                              buildWhen: (p, c) => p.obscureConfirm != c.obscureConfirm || p.confirmPassword != c.confirmPassword,
                              builder: (context, state) {
                                return PasswordInput(
                                  hint: 're-enter password',
                                  obscureText: state.obscureConfirm,
                                  onChanged: (v) => context.read<CreatePasswordBloc>().add(ConfirmPasswordChanged(v)),
                                  onToggle: () {
                                    context.read<CreatePasswordBloc>().add(const ToggleConfirmPasswordVisibility());
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'your password should contain letters and/or\n'
                                  'numbers and be at least 4 characters long.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w400,
                                color: ColorManager.otpScreenTxtGray,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // button
                            BlocBuilder<CreatePasswordBloc, CreatePasswordState>(
                              buildWhen: (p, c) => p.status != c.status,
                              builder: (context, state) {
                                final isLoading = state.status == CreatePasswordStatus.submitting;

                                return DefaultButton(
                                  label: 'continue',
                                  isLoading: isLoading,
                                  onPressed: () {
                                    context.read<CreatePasswordBloc>().add(
                                      const SubmitCreatePassword(),
                                    );
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 181),
                          ],
                        ),
                      ),
                    ),
                  ],
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
