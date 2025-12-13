import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../login/widgets/login_bottom_stripes.dart';
import '../bloc/login_otp_bloc.dart';
import '../bloc/login_otp_state.dart';
import '../repository/login_otp_repository.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<LoginOtpBloc, LoginOtpState>(
          listener: (context, state) {
            if (state.status == LoginOtpStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            // success হলে next screen এ যাওয়ার logic এখানে দিতে পারো
          },
          child: Column(
            children: [
              // scrollable content
              Expanded(
                child: Padding(
                  //padding: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: OtpHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(left: 41,right: 41),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              SizedBox(height: 24),
                              OtpCodeFields(),
                              SizedBox(height: 54),
                              OtpBottomActions(),
                              SizedBox(height: 24),
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
