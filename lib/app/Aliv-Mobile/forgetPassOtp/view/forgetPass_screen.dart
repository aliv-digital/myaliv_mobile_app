import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../login/widgets/login_bottom_stripes.dart';
import '../bloc/forgetPass_otp_bloc.dart';
import '../bloc/forgetPass_otp_state.dart';
import '../repository/forgetPass_otp_repository.dart';
import '../widgets/forgetOtp_bottom_action.dart';
import '../widgets/forgetOtp_code_fields.dart';
import '../widgets/forgetOtp_header.dart';

class ForgetPasswordOtpScreen extends StatelessWidget {
  const ForgetPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgetPasswordOtpBloc(
        repository: ForgetPasswordOtpRepository(),
      ),
      child: const _ForgetPasswordOtpView(),
    );
  }
}

class _ForgetPasswordOtpView extends StatelessWidget {
  const _ForgetPasswordOtpView();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<ForgetPasswordOtpBloc, ForgetPasswordOtpState>(
          listener: (context, state) {
            if (state.status == ForgetPasswordOtpStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            // success হলে next screen এ যাওয়ার logic এখানে দিতে পারো
          },
          child: Column(
            children: [
              // ---------- Scrollable content ----------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      const SliverToBoxAdapter(
                        child: ForgetPasswordOtpHeader(),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 41, right: 41),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              SizedBox(height: 24),
                              ForgetPasswordOtpCodeFields(),
                              SizedBox(height: 54),
                              ForgetPasswordOtpBottomActions(),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ Bottom stripes vanish when keyboard opens
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: keyboardOpen ? const SizedBox.shrink() : const BottomStripes(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
