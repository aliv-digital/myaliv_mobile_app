import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/forgetPass_otp_bloc.dart';
import '../bloc/forgetPass_otp_state.dart';
import '../repository/forgetPass_otp_repository.dart';
import '../widgets/forgetOtp_bottom_action.dart';
import '../widgets/forgetOtp_code_fields.dart';
import '../widgets/forgetOtp_header.dart';

class OtpProfilePrepaidScreen extends StatelessWidget {
  const OtpProfilePrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OtpProfilePrepaidBloc(repository: OtpProfilePrepaidRepository()),
      child: const _OtpProfilePrepaidView(),
    );
  }
}

class _OtpProfilePrepaidView extends StatelessWidget {
  const _OtpProfilePrepaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<OtpProfilePrepaidBloc, OtpProfilePrepaidState>(
          listener: (context, state) {
            if (state.status == OtpProfilePrepaidStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }

            // success হলে next screen এ যাওয়ার logic এখানে দিতে পারো
            // if (state.status == OtpProfilePrepaidStatus.success) { ... }
          },
          child: Column(
            children: [
              // scrollable content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(
                        child: OtpProfilePrepaidHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 41, right: 41),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              SizedBox(height: 24),
                              OtpProfilePrepaidCodeFields(),
                              SizedBox(height: 54),
                              OtpProfilePrepaidBottomActions(),
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
